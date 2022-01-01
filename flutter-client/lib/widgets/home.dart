import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './add_new_task.dart';
import './task_list/task_list.dart';
import './dashboard.dart';
import './settings.dart';

const _indexOfTaskList = 0;
const _indexOfDashboard = 1;
const _indexOfSettings = 2;

class Home extends StatelessWidget {
  final int selectedIndex;

  const Home({Key? key, this.selectedIndex = 0}) : super(key: key);

  static final routes = [
    GoRoute(
      path: '/',
      redirect: (_) => '/tasks',
    ),
    GoRoute(
        path: '/tasks',
        builder: (_, __) => const Home(selectedIndex: _indexOfTaskList),
        routes: TaskList.routes),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const Home(selectedIndex: _indexOfDashboard),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const Home(selectedIndex: _indexOfSettings),
    ),
    GoRoute(
      path: '/tasks/new',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const AddNewTask(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _Home(
      client: WorkrecClient(userId: userId),
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
      appBar: selectedIndex == _indexOfSettings
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
        TaskList(client: client),
        const Dashboard(),
        Settings(),
      ].elementAt(selectedIndex),
      floatingActionButton: selectedIndex == _indexOfTaskList
          ? FloatingActionButton(
              onPressed: () => _handlePresentAddTask(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _handleChangeTabIndex(BuildContext context, int index) {
    switch (index) {
      case _indexOfTaskList:
        return context.go('/tasks');
      case _indexOfDashboard:
        return context.go('/dashboard');
      case _indexOfSettings:
        return context.go('/settings');
    }
  }

  void _handlePresentAddTask(BuildContext context) {
    context.push('/tasks/new');
  }
}
