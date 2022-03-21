import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:workrec_app/workrec_client/workrec_client.dart';
import './dashboard.dart';
import './settings.dart';
import './task_list/task_list.dart';

const homeIndexOfTaskList = 0;
const homeIndexOfDashboard = 1;
const homeIndexOfSettings = 2;

class Home extends StatelessWidget {
  final int selectedIndex;

  const Home({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.read<WorkrecClient>();
    return _Home(
      client: client,
      selectedIndex: selectedIndex,
    );
  }
}

class _Home extends StatelessWidget {
  final int selectedIndex;
  final WorkrecClient client;

  const _Home({
    Key? key,
    required this.client,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == homeIndexOfSettings
          ? AppBar(
              title: const Text('設定'),
              elevation: 0,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        onTap: (index) => _handleChangeTabIndex(context, index),
        currentIndex: selectedIndex,
      ),
      body: [
        TaskListPage(client: client),
        const Dashboard(),
        Settings(),
      ].elementAt(selectedIndex),
      floatingActionButton: selectedIndex == homeIndexOfTaskList
          ? FloatingActionButton(
              onPressed: () => _handlePresentAddTask(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _handleChangeTabIndex(BuildContext context, int index) {
    switch (index) {
      case homeIndexOfTaskList:
        return context.go('/tasks');
      case homeIndexOfDashboard:
        return context.go('/dashboard');
      case homeIndexOfSettings:
        return context.go('/settings');
    }
  }

  void _handlePresentAddTask(BuildContext context) {
    context.push('/add_task');
  }
}
