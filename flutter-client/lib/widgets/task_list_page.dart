import 'package:flutter/material.dart';
import 'package:workrec/workrec/task/model.dart';

class TaskListPage extends StatelessWidget {
  TaskListPage({Key? key, required this.taskList}) : super(key: key);
  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${taskList[index].title}'),
        );
      },
    );
  }
}
