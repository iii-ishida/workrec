import 'package:flutter/material.dart';
import 'package:workrec/workrec/task/model.dart';

class TaskListPage extends StatelessWidget {
  TaskListPage({Key? key, required this.taskList}) : super(key: key);
  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => _TaskListRow(task: taskList[index]),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({Key? key, required Task task})
      : model = ViewModel(task: task),
        super(key: key);

  final ViewModel model;

  Widget _icon({required Color color}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _icon(color: model.stateColor),
            const SizedBox(width: 16),
            Text(model.title),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text(model.actionName),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewModel {
  @visibleForTesting
  ViewModel({required this.task});

  final Task task;

  String get title => task.title;
  Color get stateColor {
    switch (task.state) {
      case TaskState.started:
      case TaskState.resumed:
        return Colors.green;
      case TaskState.paused:
        return Colors.yellow;
      case TaskState.completed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String get actionName {
    switch (task.nextState) {
      case TaskState.started:
        return '開始';
      case TaskState.paused:
        return '停止';
      case TaskState.resumed:
        return '再開';
      default:
        return '-';
    }
  }
}
