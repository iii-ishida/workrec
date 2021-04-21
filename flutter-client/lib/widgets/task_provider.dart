import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';

import 'package:workrec/app/app.dart';
import 'package:workrec/domain/task_recorder/task.dart';

typedef AddTaskFunc = Future<void> Function(String);
typedef RecordTaskFunc = Future<void> Function(Task);

class TaskListProvider extends StatelessWidget {
  TaskListProvider({Key? key, required this.app, required this.child})
      : super(key: key);

  final Widget child;

  final App app;

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<App, TaskList>.value(
      value: app,
      builder: (context, _) => child,
    );
  }
}
