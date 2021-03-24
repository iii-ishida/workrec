import 'package:flutter/material.dart';
import 'package:workrec/workrec/task/model.dart';

typedef _StartFunc = Future<void> Function(Task);

class TaskListPage extends StatelessWidget {
  TaskListPage({
    Key? key,
    required this.taskList,
    required this.start,
  }) : super(key: key);

  final TaskList taskList;
  final _StartFunc start;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => _TaskListRow(
        task: taskList[index],
        start: start,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({
    Key? key,
    required Task task,
    required _StartFunc start,
  })   : model = ViewModel(
          task: task,
          start: start,
        ),
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
              onPressed: () => model.handleStart(),
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
  ViewModel({
    required this.task,
    required this.start,
  });

  final Task task;
  final _StartFunc start;

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

  Future<void> handleStart() async {
    await start(task);
  }
}
