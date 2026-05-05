import 'package:flutter/material.dart';

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
          debugPrint('Task ID: ${task.id} tapped');
        },
      ),
    );
  }
}
