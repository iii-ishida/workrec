import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

typedef _RecordTaskFunc = Future<void> Function(String);

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class TaskListPageViewModel extends ChangeNotifier {
  final WorkrecClient client;
  TaskListPageViewModel(this.client);

  List<Task> _tasks = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

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

enum ToggleAction {
  start,
  suspend,
  resume,
}

class TaskListItemViewModel extends ChangeNotifier {
  TaskListItemViewModel({
    required Task task,
    required this.onToggle,
  }) : _task = task;

  final Task _task;
  final VoidCallback onToggle;

  /// タイトル
  String get title => _task.title;

  /// 説明
  String get description => _task.description;

  /// 開始日時
  String get startTime =>
      _task.isStarted ? _dateFormat.format(_task.startTime) : '-';

  /// 作業時間
  String get workingTime {
    final workingMinutes = _task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

  /// 次のアクション
  /// 開始, 停止 or 再開
  ToggleAction get toggleAction {
    if (!_task.isStarted) {
      return ToggleAction.start;
    } else if (_task.isWorking) {
      return ToggleAction.suspend;
    } else {
      return ToggleAction.resume;
    }
  }
}
