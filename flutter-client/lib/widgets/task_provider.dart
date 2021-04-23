import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec/app/app.dart';
import 'package:workrec/domain/task_recorder/task.dart';

typedef AddTaskFunc = Future<void> Function(String);
typedef RecordTaskFunc = Future<void> Function(Task);

class TaskListProvider extends StatefulWidget {
  final Widget child;
  final App app;

  TaskListProvider({
    Key? key,
    required this.app,
    required this.child,
  }) : super(key: key);

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<TaskListProvider> {
  late final StreamSubscription<TaskList> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.app.listenTaskList();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<App, TaskList>.value(
      value: widget.app,
      builder: (context, _) => widget.child,
    );
  }
}
