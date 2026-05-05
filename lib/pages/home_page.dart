import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

// ナビゲーションを管理する親ウィジェット
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 表示する画面のリスト
  static const List<Widget> _pages = [
    HomePage(),
    Center(child: Text('Ranking Page')), // ランキング画面（仮）
    Center(child: Text('Account Page')), // アカウント画面（仮）
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// ホーム画面のコンテンツ
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // 画面が溢れないようにスクロール可能に
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ポイント表示セクション
            _buildPointCard(),
            const SizedBox(height: 24),

            // 2. Daily Tasks
            const Text('Daily Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildTaskTile('朝の散歩', true),
            _buildTaskTile('読書 15分', false),
            const SizedBox(height: 24),

            // 3. Optional Tasks
            const Text('Optional Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildTaskTile('部屋の掃除', false),
            _buildTaskTile('新しいレシピに挑戦', false),
          ],
        ),
      ),
    );
  }

  // ポイント表示のカード
  Widget _buildPointCard() {
    return Card(
      elevation: 4,
      color: Colors.deepPurple,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Points:', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('1,250 pt', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // タスク一行分のデザイン
  Widget _buildTaskTile(String title, bool isDone) {
    return Card(
      child: ListTile(
        leading: Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? Colors.green : Colors.grey,
        ),
        title: Text(title, style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // タスク詳細や完了処理をここに書く
        },
      ),
    );
  }
}