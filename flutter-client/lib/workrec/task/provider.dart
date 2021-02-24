import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec/task/repo.dart';

import 'model.dart';

class TaskListProvider extends StatelessWidget {
  final String userId;
  final Widget Function(BuildContext context, TaskList taskList) builder;
  TaskListProvider({
    Key? key,
    required this.userId,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TaskList>(
      initialData: TaskList(tasks: []),
      create: (_) => TaskListRepo().watch(userId),
      child: Consumer<TaskList>(
        builder: (context, value, _) => builder(context, value),
      ),
    );
  }
}
