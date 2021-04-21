import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workrec/app/app.dart';
import 'package:workrec/domain/task_recorder/task.dart';

typedef AddTaskFunc = Future<void> Function(String);
typedef RecordTaskFunc = Future<void> Function(Task);

class TaskListProvider extends StatelessWidget {
  TaskListProvider({Key? key, required this.app, required this.builder})
      : super(key: key);

  final Widget Function(
    BuildContext context,
    TaskList taskList,
  ) builder;

  final App app;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TaskList>.value(
      initialData: TaskList([]),
      value: app.fetchTaskList(),
      child: Consumer<TaskList>(
        builder: (context, value, _) => builder(context, value),
      ),
    );
  }
}
