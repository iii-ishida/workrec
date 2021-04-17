import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import './task_provider.dart';

class TaskListPage extends StatelessWidget {
  final TaskList taskList;
  final TaskCommand command;

  TaskListPage({
    Key? key,
    required this.taskList,
    required this.command,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => _TaskListRow(
        task: taskList[index],
        command: command,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({
    Key? key,
    required Task task,
    required TaskCommand command,
  })  : model = ViewModel(
          task: task,
          start: command.startTask,
          pause: command.pauseTask,
          resume: command.resumeTask,
        ),
        super(key: key);

  final ViewModel model;

  Widget _icon({required Color color}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const _space = SizedBox(height: 8, width: 8);
    final _iconSpace = _icon(color: Colors.transparent);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _icon(color: model.stateColor),
                  _space,
                  Text(
                    model.title,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ]),
                _space,
                Row(children: [
                  _iconSpace,
                  _space,
                  Text(
                    model.startedAt,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ]),
                Row(children: [
                  _iconSpace,
                  _space,
                  Text(
                    '作業時間: ${model.workingTime}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ]),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => model.handleToggle(),
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
    required this.pause,
    required this.resume,
  });

  final Task task;
  final RecordTaskFunc start;
  final RecordTaskFunc pause;
  final RecordTaskFunc resume;

  final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  String get title => task.title;
  String get startedAt =>
      task.isStarted ? _dateFormat.format(task.startedAt) : '';

  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

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

  Future<void> handleToggle() async {
    switch (task.nextState) {
      case TaskState.started:
        return await _handleStart();
      case TaskState.paused:
        return await _handlePause();
      case TaskState.resumed:
        return await _handleResume();
      default:
    }
  }

  Future<void> _handleStart() async {
    await start(task);
  }

  Future<void> _handlePause() async {
    await pause(task);
  }

  Future<void> _handleResume() async {
    await resume(task);
  }
}
