import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

typedef _RecordTaskFunc = Future<void> Function(String);

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class TaskListPageViewModel extends ChangeNotifier {
  final WorkrecClient client;
  List<Task> _tasks = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TaskListPageViewModel(this.client);

  void listen() {
    client.tasksStream().listen((tasks) {
      _isLoading = false;
      _tasks = tasks;
      notifyListeners();
    });
  }

  void onChangeSearchText(String searchTest) {}

  TaskListViewModel get taskListViewModel => TaskListViewModel(
        tasks: _tasks,
        startTask: (id) => client.startTask(id, clock.now()),
        suspendTask: (id) => client.suspendTask(id, clock.now()),
        resumeTask: (id) => client.resumeTask(id, clock.now()),
      );
}

class TaskListViewModel {
  final List<Task> tasks;
  final _RecordTaskFunc startTask;
  final _RecordTaskFunc suspendTask;
  final _RecordTaskFunc resumeTask;

  TaskListViewModel({
    required this.tasks,
    required this.startTask,
    required this.suspendTask,
    required this.resumeTask,
  });

  List<TaskListItemViewModel> get rows => tasks
      .map(
        (task) => TaskListItemViewModel(
          task: task,
          onToggle: () => _handleToggle(task),
        ),
      )
      .toList();

  Future<void> _handleToggle(Task task) async {
    if (!task.isStarted) {
      await startTask(task.id);
    }
    if (task.isWorking) {
      await suspendTask(task.id);
    } else {
      await resumeTask(task.id);
    }
  }
}

class TaskListItemViewModel extends ChangeNotifier {
  TaskListItemViewModel({
    required this.task,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onToggle;

  String get title => task.title;
  String get startTime =>
      task.isStarted ? _dateFormat.format(task.startTime) : '-';

  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

  /// トグルボタンのラベル内容
  String get toggleButtonLabel {
    if (!task.isStarted) {
      return '開始';
    } else if (task.isWorking) {
      return '停止';
    } else {
      return '再開';
    }
  }

  /// トグルボタンの表示を停止にする場合は true
  bool get isNextSuspend => !task.isWorking;
}
