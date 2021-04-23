import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec/controllers/task_controller.dart';
import 'package:workrec/domain/task_recorder/task.dart';

typedef AddTaskFunc = Future<void> Function(String);
typedef RecordTaskFunc = Future<void> Function(Task);

class TaskListProvider extends StatefulWidget {
  final Widget child;
  final TaskController controller;

  TaskListProvider({
    Key? key,
    required this.controller,
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
    _subscription = widget.controller.listenTaskList();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<TaskController, TaskList>.value(
      value: widget.controller,
      builder: (context, _) => widget.child,
    );
  }
}
