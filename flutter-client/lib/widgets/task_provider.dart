import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/task_repo.dart';

typedef AddTaskFunc = Future<void> Function(String);
typedef RecordTaskFunc = Future<void> Function(Task);

class TaskCommand {
  final AddTaskFunc addTask;
  final RecordTaskFunc startTask;
  final RecordTaskFunc pauseTask;
  final RecordTaskFunc resumeTask;

  TaskCommand({
    required this.addTask,
    required this.startTask,
    required this.pauseTask,
    required this.resumeTask,
  });
}

class TaskListProvider extends StatelessWidget {
  final TaskListRepo repo;
  final Widget Function(
    BuildContext context,
    TaskCommand command,
    TaskList taskList,
  ) builder;

  final TaskCommand _command;

  TaskListProvider({
    Key? key,
    required this.repo,
    required this.builder,
  })  : _command = TaskCommand(
          addTask: repo.addTask,
          startTask: repo.start,
          pauseTask: repo.pause,
          resumeTask: repo.resume,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TaskList>.value(
      initialData: TaskList([]),
      value: repo.taskList(),
      child: Consumer<TaskList>(
        builder: (context, value, _) => builder(context, _command, value),
      ),
    );
  }
}
