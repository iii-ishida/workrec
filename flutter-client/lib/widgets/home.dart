import 'package:flutter/material.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './task_list/task_list.dart';

class Home extends StatefulWidget {
  final WorkrecClient client;

  const Home({Key? key, required this.client}) : super(key: key);

  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_sharp),
            label: '作業中',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
      body: [
        TaskList(client: widget.client),
        const Placeholder(),
        const Placeholder(),
      ].elementAt(_selectedIndex),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
