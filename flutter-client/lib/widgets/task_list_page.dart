import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:provider/provider.dart';
import 'package:workrec/repositories/task_repo.dart';

typedef _RecordTaskFunc = Future<void> Function(Task);

class TaskListPage extends StatelessWidget {
  final TaskListRepo repo;

  const TaskListPage({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Task>>(
      create: (_) => repo.taskList(),
      initialData: const [],
      child: Builder(builder: (context) {
        final taskList = context.read<List<Task>>();
        return _TaskListView(
          taskList: taskList,
          startTask: repo.start,
          suspendTask: repo.suspend,
          resumeTask: repo.resume,
        );
      }),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final List<Task> taskList;
  final _RecordTaskFunc startTask;
  final _RecordTaskFunc suspendTask;
  final _RecordTaskFunc resumeTask;

  const _TaskListView({
    Key? key,
    required this.taskList,
    required this.startTask,
    required this.suspendTask,
    required this.resumeTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskList = context.watch<List<Task>>();

    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => _TaskListRow(
        task: taskList[index],
        startTask: startTask,
        suspendTask: suspendTask,
        resumeTask: resumeTask,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({
    Key? key,
    required Task task,
    required _RecordTaskFunc startTask,
    required _RecordTaskFunc suspendTask,
    required _RecordTaskFunc resumeTask,
  })  : model = ViewModel(
          task: task,
          start: startTask,
          suspend: suspendTask,
          resume: resumeTask,
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
                    model.startTime,
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
    required this.suspend,
    required this.resume,
  });

  final Task task;
  final _RecordTaskFunc start;
  final _RecordTaskFunc suspend;
  final _RecordTaskFunc resume;

  final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  String get title => task.title;
  String get startTime =>
      task.isStarted ? _dateFormat.format(task.startTime) : '';

  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

  Color get stateColor {
    if (!task.isStarted) {
      return Colors.grey;
    }
    if (task.isWorking) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  String get actionName {
    if (!task.isStarted) {
      return '開始';
    } else if (task.isWorking) {
      return '停止';
    } else {
      return '再開';
    }
  }

  Future<void> handleToggle() async {
    if (!task.isStarted) {
      return await _handleStart();
    }
    if (task.isWorking) {
      return await _handleSuspend();
    } else {
      return await _handleResume();
    }
  }

  Future<void> _handleStart() async {
    await start(task);
  }

  Future<void> _handleSuspend() async {
    await suspend(task);
  }

  Future<void> _handleResume() async {
    await resume(task);
  }
}
