import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../services/gps_accelerometer_gyro.dart';
import '../widgets/stat_card.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final String category;
  final int points;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.category,
    required this.points,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _points = 1250;
  static const double _weeklyDistanceKm = 32;
  static const double _weeklyGoalKm = 50;
  static const double _co2SavedKg = 18.4;

  final List<Task> _tasks = const [
    Task(
      id: 'task_001',
      title: 'Cycle to work',
      description: 'Complete one commute by bicycle today.',
      isDone: false,
      category: 'Today',
      points: 100,
    ),
    Task(
      id: 'task_002',
      title: 'Log your ride',
      description: 'Submit GPS tracking and motion data.',
      isDone: true,
      category: 'Today',
      points: 50,
    ),
    Task(
      id: 'task_003',
      title: 'Replace a short drive',
      description: 'Use a bike for an errand under 5 km.',
      isDone: false,
      category: 'Bonus',
      points: 75,
    ),
  ];

  bool _gpsLoading = false;

  void _showSensorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SensorSheet(),
    );
  }

  Future<void> _testGps() async {
    setState(() => _gpsLoading = true);
    try {
      final position = await SensorService.instance.getCurrentPosition();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'GPS OK  Lat ${position.latitude.toStringAsFixed(6)}, '
            'Lng ${position.longitude.toStringAsFixed(6)}, '
            'Accuracy ${position.accuracy.toStringAsFixed(1)} m',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_weeklyDistanceKm / _weeklyGoalKm).clamp(0.0, 1.0);
    final todayTasks = _tasks.where((task) => task.category == 'Today');
    final bonusTasks = _tasks.where((task) => task.category == 'Bonus');

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Dashboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _HeroPanel(
            progress: progress,
            weeklyDistanceKm: _weeklyDistanceKm,
            weeklyGoalKm: _weeklyGoalKm,
            onSensorsPressed: _showSensorSheet,
            onGpsPressed: _gpsLoading ? null : _testGps,
            gpsLoading: _gpsLoading,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Points',
                  value: '$_points',
                  color: colorScheme.primary,
                  icon: Icons.stars_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'CO2 Saved',
                  value: '${_co2SavedKg.toStringAsFixed(1)} kg',
                  color: colorScheme.secondary,
                  icon: Icons.air_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Today',
            actionText:
                '${todayTasks.where((task) => task.isDone).length}/'
                '${todayTasks.length} done',
          ),
          const SizedBox(height: 10),
          ...todayTasks.map((task) => TaskTile(task: task)),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Bonus', actionText: '+75 available'),
          const SizedBox(height: 10),
          ...bonusTasks.map((task) => TaskTile(task: task)),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final double progress;
  final double weeklyDistanceKm;
  final double weeklyGoalKm;
  final VoidCallback onSensorsPressed;
  final VoidCallback? onGpsPressed;
  final bool gpsLoading;

  const _HeroPanel({
    required this.progress,
    required this.weeklyDistanceKm,
    required this.weeklyGoalKm,
    required this.onSensorsPressed,
    required this.onGpsPressed,
    required this.gpsLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.directions_bike),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly goal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weeklyDistanceKm.toStringAsFixed(0)} of '
                        '${weeklyGoalKm.toStringAsFixed(0)} km completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.75),
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onGpsPressed,
                    icon: gpsLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.gps_fixed),
                    label: const Text('GPS'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSensorsPressed,
                    icon: const Icon(Icons.sensors),
                    label: const Text('Sensors'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionHeader({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            actionText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorSheet extends StatefulWidget {
  const _SensorSheet();

  @override
  State<_SensorSheet> createState() => _SensorSheetState();
}

class _SensorSheetState extends State<_SensorSheet> {
  final _service = SensorService.instance;

  @override
  void initState() {
    super.initState();
    _service.start();
  }

  @override
  void dispose() {
    _service.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live sensors',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          StreamBuilder<SensorSnapshot>(
            stream: _service.snapshots,
            builder: (context, snap) {
              final data = snap.data;
              return Column(
                children: [
                  _SensorTile(
                    icon: Icons.gps_fixed,
                    label: 'GPS',
                    color: colorScheme.primary,
                    lines: data?.gps == null
                        ? ['Waiting for fix']
                        : [
                            'Lat ${data!.gps!.latitude.toStringAsFixed(6)}',
                            'Lng ${data.gps!.longitude.toStringAsFixed(6)}',
                            'Speed ${data.gps!.speed.toStringAsFixed(1)} m/s',
                            'Accuracy ${data.gps!.accuracy.toStringAsFixed(1)} m',
                          ],
                  ),
                  const SizedBox(height: 10),
                  _SensorTile(
                    icon: Icons.vibration,
                    label: 'Accelerometer',
                    color: colorScheme.tertiary,
                    lines: data == null
                        ? ['Starting']
                        : [
                            'X ${data.accelerometer.x.toStringAsFixed(3)}',
                            'Y ${data.accelerometer.y.toStringAsFixed(3)}',
                            'Z ${data.accelerometer.z.toStringAsFixed(3)}',
                          ],
                  ),
                  const SizedBox(height: 10),
                  _SensorTile(
                    icon: Icons.rotate_right,
                    label: 'Gyroscope',
                    color: const Color(0xFF0277BD),
                    lines: data == null
                        ? ['Starting']
                        : [
                            'X ${data.gyroscope.x.toStringAsFixed(3)}',
                            'Y ${data.gyroscope.y.toStringAsFixed(3)}',
                            'Z ${data.gyroscope.z.toStringAsFixed(3)}',
                          ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<String> lines;

  const _SensorTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 6),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: task.isDone
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerLowest,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isDone ? colorScheme.primary : colorScheme.outline,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(task.description),
        ),
        trailing: Text(
          '+${task.points}',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => TaskMapPage(task: task)),
          );
        },
      ),
    );
  }
}

class TaskMapPage extends StatefulWidget {
  final Task task;

  const TaskMapPage({super.key, required this.task});

  @override
  State<TaskMapPage> createState() => _TaskMapPageState();
}

class _TaskMapPageState extends State<TaskMapPage> {
  static const _sendaiStation = _GeoPoint(
    label: 'Sendai Station',
    latitude: 38.2562,
    longitude: 140.8758,
  );
  static const _ayashiStation = _GeoPoint(
    label: 'Ayashi Station',
    latitude: 38.2702,
    longitude: 140.7570,
  );

  bool _loadingLocation = true;
  bool _loadingRoute = true;
  String? _locationError;
  String? _routeError;
  _GeoPoint? _currentLocation;
  List<LatLng> _routePoints = const [];
  double _routeDistanceKm = 15.2;

  @override
  void initState() {
    super.initState();
    _loadRoute();
    _loadCurrentLocation();
  }

  Future<void> _loadRoute() async {
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    try {
      final uri = Uri.https(
        'router.project-osrm.org',
        '/route/v1/driving/'
            '${_sendaiStation.longitude},${_sendaiStation.latitude};'
            '${_ayashiStation.longitude},${_ayashiStation.latitude}',
        {'overview': 'full', 'geometries': 'geojson'},
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw 'Route API failed: ${response.statusCode}';
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'] as List<dynamic>;
      if (routes.isEmpty) throw 'No route found.';

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final points = coordinates.map((coordinate) {
        final pair = coordinate as List<dynamic>;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _routeDistanceKm =
            ((route['distance'] as num?)?.toDouble() ?? 15200) / 1000;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _routeError = '$e';
        _routePoints = [_sendaiStation.latLng, _ayashiStation.latLng];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
        });
      }
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await SensorService.instance.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLocation = _GeoPoint(
          label: 'Current location',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routePoints = _routePoints.isEmpty
        ? [_sendaiStation.latLng, _ayashiStation.latLng]
        : _routePoints;
    final routeProgress = _RouteProgress.fromRoute(
      routePoints: routePoints,
      routeDistanceKm: _routeDistanceKm,
      current: _currentLocation,
      fallbackProgress: widget.task.isDone ? 1.0 : 0.0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Task Map')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        child: Icon(
                          widget.task.isDone
                              ? Icons.check_circle
                              : Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.task.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _DetailChip(
                        icon: Icons.stars_outlined,
                        label: '+${widget.task.points} points',
                      ),
                      const SizedBox(width: 8),
                      _DetailChip(
                        icon: widget.task.isDone
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        label: widget.task.isDone ? 'Completed' : 'In progress',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(routeProgress.progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: routeProgress.progress,
                      minHeight: 12,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    routeProgress.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            color: colorScheme.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Row(
                    children: [
                      Text(
                        'Route map',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Refresh current location',
                        onPressed: _loadingLocation
                            ? null
                            : _loadCurrentLocation,
                        icon: _loadingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(38.2632, 140.8164),
                      initialZoom: 12,
                      minZoom: 9,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        userAgentPackageName: 'cybon_front',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: colorScheme.primary,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          _mapMarker(
                            point: _sendaiStation.latLng,
                            color: colorScheme.primary,
                            icon: Icons.trip_origin,
                          ),
                          _mapMarker(
                            point: _ayashiStation.latLng,
                            color: colorScheme.secondary,
                            icon: Icons.flag,
                          ),
                          if (_currentLocation != null)
                            _mapMarker(
                              point: _currentLocation!.latLng,
                              color: colorScheme.tertiary,
                              icon: Icons.my_location,
                              size: 44,
                            ),
                        ],
                      ),
                      SimpleAttributionWidget(
                        source: const Text('OpenStreetMap contributors, CARTO'),
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: Column(
                    children: [
                      if (_loadingRoute || _routeError != null) ...[
                        _RouteLocationRow(
                          icon: _routeError == null
                              ? Icons.route
                              : Icons.info_outline,
                          label: 'Route',
                          value: _routeError == null
                              ? 'Loading real route'
                              : 'Showing fallback route: $_routeError',
                          color: _routeError == null
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _RouteLocationRow(
                        icon: Icons.trip_origin,
                        label: _sendaiStation.label,
                        value:
                            '${_sendaiStation.latitude.toStringAsFixed(4)}, '
                            '${_sendaiStation.longitude.toStringAsFixed(4)}',
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      _RouteLocationRow(
                        icon: Icons.location_on_outlined,
                        label: _ayashiStation.label,
                        value:
                            '${_ayashiStation.latitude.toStringAsFixed(4)}, '
                            '${_ayashiStation.longitude.toStringAsFixed(4)}',
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      _RouteLocationRow(
                        icon: Icons.my_location,
                        label: 'Current location',
                        value: _currentLocation == null
                            ? (_locationError ?? 'Waiting for GPS permission')
                            : '${_currentLocation!.latitude.toStringAsFixed(4)}, '
                                  '${_currentLocation!.longitude.toStringAsFixed(4)}',
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(label: 'Task ID', value: widget.task.id),
                  _DetailRow(label: 'Category', value: widget.task.category),
                  const _DetailRow(label: 'Start', value: 'Sendai Station'),
                  const _DetailRow(label: 'Stop', value: 'Ayashi Station'),
                  _DetailRow(
                    label: 'Route distance',
                    value: '${_routeDistanceKm.toStringAsFixed(1)} km',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _mapMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    double size = 38,
  }) {
    return Marker(
      point: point,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.52),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteLocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RouteLocationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoPoint {
  final String label;
  final double latitude;
  final double longitude;

  const _GeoPoint({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}

class _RouteProgress {
  final double progress;
  final String description;

  const _RouteProgress({required this.progress, required this.description});

  factory _RouteProgress.fromRoute({
    required List<LatLng> routePoints,
    required double routeDistanceKm,
    required _GeoPoint? current,
    required double fallbackProgress,
  }) {
    if (current == null || routePoints.length < 2) {
      return _RouteProgress(
        progress: fallbackProgress,
        description: 'GPS location is not available yet.',
      );
    }

    final projectedDistanceMeters = _projectDistanceOnRoute(
      routePoints: routePoints,
      current: current.latLng,
    );
    final routeDistanceMeters = math.max(routeDistanceKm * 1000, 1);
    final progress = (projectedDistanceMeters / routeDistanceMeters).clamp(
      0.0,
      1.0,
    );
    final remainingKm = (routeDistanceKm * (1 - progress)).clamp(
      0.0,
      routeDistanceKm,
    );

    return _RouteProgress(
      progress: progress,
      description:
          '${remainingKm.toStringAsFixed(1)} km remaining to Ayashi Station.',
    );
  }

  static double _projectDistanceOnRoute({
    required List<LatLng> routePoints,
    required LatLng current,
  }) {
    var distanceBeforeSegment = 0.0;
    var bestDistanceAlongRoute = 0.0;
    var bestDistanceToRoute = double.infinity;

    for (var i = 0; i < routePoints.length - 1; i += 1) {
      final start = routePoints[i];
      final end = routePoints[i + 1];
      final segmentDistance = _distanceMeters(start, end);
      final projection = _projectPointOnSegment(
        start: start,
        end: end,
        current: current,
      );
      final projectedPoint = LatLng(
        start.latitude + (end.latitude - start.latitude) * projection,
        start.longitude + (end.longitude - start.longitude) * projection,
      );
      final distanceToRoute = _distanceMeters(current, projectedPoint);

      if (distanceToRoute < bestDistanceToRoute) {
        bestDistanceToRoute = distanceToRoute;
        bestDistanceAlongRoute =
            distanceBeforeSegment + segmentDistance * projection;
      }

      distanceBeforeSegment += segmentDistance;
    }

    return bestDistanceAlongRoute;
  }

  static double _projectPointOnSegment({
    required LatLng start,
    required LatLng end,
    required LatLng current,
  }) {
    final dx = end.longitude - start.longitude;
    final dy = end.latitude - start.latitude;
    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0) return 0;

    final projection =
        ((current.longitude - start.longitude) * dx +
            (current.latitude - start.latitude) * dy) /
        lengthSquared;

    return projection.clamp(0.0, 1.0);
  }

  static double _distanceMeters(LatLng a, LatLng b) {
    const earthRadiusMeters = 6371000.0;
    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);
    final dLat = _degreesToRadians(b.latitude - a.latitude);
    final dLng = _degreesToRadians(b.longitude - a.longitude);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    return earthRadiusMeters * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
