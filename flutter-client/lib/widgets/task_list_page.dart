import 'package:flutter/material.dart';
import 'package:workrec/workrec/task/model.dart';

typedef _StartFunc = Future<void> Function(Task);
typedef _PauseFunc = Future<void> Function(Task);
typedef _ResumeFunc = Future<void> Function(Task);

class TaskListPage extends StatelessWidget {
  TaskListPage({
    Key? key,
    required this.taskList,
    required this.start,
    required this.pause,
    required this.resume,
  }) : super(key: key);

  final TaskList taskList;
  final _StartFunc start;
  final _PauseFunc pause;
  final _ResumeFunc resume;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) => _TaskListRow(
        task: taskList[index],
        start: start,
        pause: pause,
        resume: resume,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({
    Key? key,
    required Task task,
    required _StartFunc start,
    required _PauseFunc pause,
    required _ResumeFunc resume,
  })   : model = ViewModel(
          task: task,
          start: start,
          pause: pause,
          resume: resume,
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
            Text(model.workingTime),
            const SizedBox(width: 32),
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
  final _StartFunc start;
  final _PauseFunc pause;
  final _ResumeFunc resume;

  String get title => task.title;

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