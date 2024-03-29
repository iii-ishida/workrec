import 'package:flutter/material.dart';
import 'package:workrec/page/task_detail.dart';
import './task_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const TaskListPage(),
        const TaskDetail(),
        const Placeholder(),
      ][_index],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: (index) => setState(() => _index = index),
        currentIndex: _index,
      ),
    );
  }
}
