import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/widgets/auth/user_id_notifier.dart';

import './task_list/task_list.dart';

class Home extends StatelessWidget {
  final int selectedIndex;

  const Home({Key? key, this.selectedIndex = 0}) : super(key: key);

  static final routes = [
    GoRoute(
      path: '/',
      redirect: (_) => '/list',
    ),
    GoRoute(
      path: '/list',
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
  ];

  @override
  Widget build(BuildContext context) {
    final userId = userIdOf(context);
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
              onPressed: _handlePresentAddTask,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _handleChangeTabIndex(BuildContext context, int index) {
    if (index == 0) {
      context.go('/list');
    }
    if (index == 1) {
      context.go('/working');
    }
    if (index == 2) {
      context.go('/settings');
    }
  }

  void _handlePresentAddTask() {}
}
