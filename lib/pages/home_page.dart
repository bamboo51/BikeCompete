import 'package:flutter/material.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// 3. ホーム画面：データを受け取って表示するだけのStatelessWidget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final int _points = 10;

  // サンプルデータ（将来的にバックエンドから取得するリスト）
  final List<Task> _tasks = const [
    Task(id: '1', title: 'TASK1', isDone: true,category: 'Daily'),
    Task(id: '2', title: 'TASK2', isDone: false,category: 'Daily'),
    Task(id: '3', title: 'TASK3', isDone: false,category: 'Optional'),
    Task(id: '4', title: 'TASK4', isDone: true, category: 'Optional'),
    
  ];
 
  @override
  Widget build(BuildContext context) {
    // カテゴリごとにデータをフィルタリング
    final dailyTasks = _tasks.where((t) => t.category == 'Daily').toList();
    final optionalTasks = _tasks.where((t) => t.category == 'Optional').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointCard(_points), // ポイント表示
            const SizedBox(height: 24),
            
            const Text('Daily Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...dailyTasks.map((task) => TaskTile(task: task)).toList(),
            
            const SizedBox(height: 24),
            
            const Text('Optional Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...optionalTasks.map((task) => TaskTile(task: task)).toList(),
          ],
        ),
      ),
    );
  }

  // ポイント表示セクション
  Widget _buildPointCard(int points) {
    return Card(
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Current Points', style: TextStyle(color: Colors.white)),
            Text('$points pt', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 4. 個別のタスク部品：独立させることで管理しやすくする
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
          style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: () {
          // TODO: バックエンドに完了フラグを飛ばす処理をここに書く
          print('Task ID: ${task.id} tapped');
        },
      ),
    );
  }
}