import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec/task/repo.dart';

import 'models/task.dart';

class TaskListProvider extends StatelessWidget {
  final TaskListRepo repo;
  final Widget Function(
    BuildContext context,
    TaskListRepo repo,
    TaskList taskList,
  ) builder;

  TaskListProvider({
    Key? key,
    required this.repo,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TaskList>.value(
      initialData: TaskList(tasks: []),
      value: repo.taskList(),
      child: Consumer<TaskList>(
        builder: (context, value, _) => builder(context, repo, value),
      ),
    );
  }
}
