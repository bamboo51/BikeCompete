import 'package:flutter/material.dart';
import '../services/gps_accelerometer_gyro.dart';

void main() {
  runApp(const MyApp());
}

// 1. データモデル：バックエンドに渡す際や、受け取る際の設計図
class Task {
  final String id; // バックエンドでの識別用
  final String title;
  final bool isDone;
  final String category; // 'Daily' or 'Optional'

  const Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.category,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// 2. ナビゲーション管理：Statefulを使うのはここだけに留める
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    Center(child: Text('Ranking Page')),
    Center(child: Text('Account Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// 3. ホーム画面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _points = 10;

  final List<Task> _tasks = const [
    Task(id: '1', title: 'TASK1', isDone: true, category: 'Daily'),
    Task(id: '2', title: 'TASK2', isDone: false, category: 'Daily'),
    Task(id: '3', title: 'TASK3', isDone: false, category: 'Optional'),
    Task(id: '4', title: 'TASK4', isDone: true, category: 'Optional'),
  ];

  bool _gpsLoading = false;

  void _showSensorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
            'GPS OK\n'
            'Lat: ${position.latitude.toStringAsFixed(6)}\n'
            'Lng: ${position.longitude.toStringAsFixed(6)}\n'
            'Accuracy: ${position.accuracy.toStringAsFixed(1)} m',
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS error: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyTasks = _tasks.where((t) => t.category == 'Daily').toList();
    final optionalTasks = _tasks.where((t) => t.category == 'Optional').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'sensors',
            onPressed: _showSensorSheet,
            tooltip: 'Live Sensors',
            child: const Icon(Icons.sensors),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'gps',
            onPressed: _gpsLoading ? null : _testGps,
            tooltip: 'Test GPS',
            child: _gpsLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.gps_fixed),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointCard(_points),
            const SizedBox(height: 24),
            const Text(
              'Daily Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...dailyTasks.map((task) => TaskTile(task: task)),
            const SizedBox(height: 24),
            const Text(
              'Optional Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...optionalTasks.map((task) => TaskTile(task: task)),
          ],
        ),
      ),
    );
  }

  Widget _buildPointCard(int points) {
    return Card(
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Current Points', style: TextStyle(color: Colors.white)),
            Text(
              '$points pt',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Live sensor bottom sheet
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Live Sensors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    color: Colors.green,
                    lines: data?.gps == null
                        ? ['Waiting for fix…']
                        : [
                            'Lat:  ${data!.gps!.latitude.toStringAsFixed(6)}',
                            'Lng:  ${data.gps!.longitude.toStringAsFixed(6)}',
                            'Speed: ${data.gps!.speed.toStringAsFixed(1)} m/s',
                            'Acc:   ±${data.gps!.accuracy.toStringAsFixed(1)} m',
                          ],
                  ),
                  const SizedBox(height: 8),
                  _SensorTile(
                    icon: Icons.vibration,
                    label: 'Accelerometer (m/s²)',
                    color: Colors.orange,
                    lines: data == null
                        ? ['Starting…']
                        : [
                            'X: ${data.accelerometer.x.toStringAsFixed(3)}',
                            'Y: ${data.accelerometer.y.toStringAsFixed(3)}',
                            'Z: ${data.accelerometer.z.toStringAsFixed(3)}',
                          ],
                  ),
                  const SizedBox(height: 8),
                  _SensorTile(
                    icon: Icons.rotate_right,
                    label: 'Gyroscope (rad/s)',
                    color: Colors.blue,
                    lines: data == null
                        ? ['Starting…']
                        : [
                            'X: ${data.gyroscope.x.toStringAsFixed(3)}',
                            'Y: ${data.gyroscope.y.toStringAsFixed(3)}',
                            'Z: ${data.gyroscope.z.toStringAsFixed(3)}',
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 4),
                ...lines.map((l) => Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. 個別のタスク部品：独立させることで管理しやすくする
class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isDone ? Colors.green : Colors.grey,
        ),
        title: Text(
          task.title, // 修正：task.title
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: () {
          // TODO: バックエンドに完了フラグを飛ばす処理をここに書く
          debugPrint('Task ID: ${task.id} tapped');
        },
      ),
    );
  }
}
