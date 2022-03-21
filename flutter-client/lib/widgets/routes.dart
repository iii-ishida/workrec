import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:workrec_app/widgets/add_new_task.dart';
import 'package:workrec_app/widgets/auth/sign_in.dart';
import 'package:workrec_app/widgets/auth/sign_up.dart';
import 'package:workrec_app/widgets/edit_task.dart';
import 'package:workrec_app/widgets/home.dart';
import 'package:workrec_app/widgets/task_detail.dart';
import 'package:workrec_app/widgets/work_time_list/work_time_list.dart';

final routes = [
  GoRoute(
    name: 'signIn',
    path: '/signIn',
    builder: (_, __) => const SignIn(),
  ),
  GoRoute(
    name: 'signUp',
    path: '/signUp',
    builder: (_, __) => const SignUp(),
  ),
  GoRoute(
    path: '/',
    redirect: (_) => '/tasks',
  ),
  GoRoute(
    path: '/tasks',
    builder: (_, __) => const Home(selectedIndex: homeIndexOfTaskList),
  ),
  GoRoute(
    path: '/dashboard',
    builder: (_, __) => const Home(selectedIndex: homeIndexOfDashboard),
  ),
  GoRoute(
    path: '/settings',
    builder: (_, __) => const Home(selectedIndex: homeIndexOfSettings),
  ),
  GoRoute(
    path: '/add_task',
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      fullscreenDialog: true,
      child: const AddNewTask(),
    ),
  ),
  GoRoute(
    path: '/tasks/:id',
    builder: (_, state) => TaskDetail(taskId: state.params['id']!),
  ),
  GoRoute(
    path: '/tasks/:id/work-times',
    builder: (_, state) => WorkTimeList(taskId: state.params['id']!),
  ),
  GoRoute(
    path: '/tasks/:id/edit',
    builder: (_, state) => EditTask(taskId: state.params['id']!),
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      child: EditTask(taskId: state.params['id']!),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  ),
];
