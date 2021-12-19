import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './add_new_task.dart';
import './task_list/task_list.dart';

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
      builder: (_, __) => const Home(selectedIndex: 0),
    ),
    GoRoute(
      path: '/working',
      builder: (_, __) => const Home(selectedIndex: 1),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const Home(selectedIndex: 2),
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
        onTap: (index) => _handleChangeTabIndex(context, index),
        currentIndex: selectedIndex,
      ),
      body: [
        TaskList(client: client),
        const Placeholder(),
        const Placeholder(),
      ].elementAt(selectedIndex),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _handlePresentAddTask(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _handleChangeTabIndex(BuildContext context, int index) {
    if (index == 0) {
      context.go('/tasks');
    }
    if (index == 1) {
      context.go('/working');
    }
    if (index == 2) {
      context.go('/settings');
    }
  }

  void _handlePresentAddTask(BuildContext context) {
    context.push('/tasks/new');
  }
}
