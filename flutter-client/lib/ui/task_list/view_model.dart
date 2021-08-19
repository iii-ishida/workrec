import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/task_recorder.dart';
import 'package:workrec/repository/task_recorder/task_repo.dart';

import './widgets/current_task.dart';

typedef _RecordTaskFunc = Future<void> Function(String);

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class TaskListPageViewModel extends ChangeNotifier {
  final TaskListRepo repo;
  TaskRecorder _recorder = TaskRecorder(tasks: const [], currentTaskId: '');

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  TaskListPageViewModel(this.repo);

  void listen() {
    repo.taskRecorder().listen((recorder) {
      _isLoading = false;
      _recorder = recorder;
      notifyListeners();
    });
  }

  void onChangeSearchText(String searchTest) {}

  void onAddTask(String title) {
    repo.addNewTask(_recorder, title);
  }

  String get currentTaskId => _recorder.currentTaskId;
  CurrentTaskViewModel get currentTaskViewModel =>
      CurrentTaskViewModel(_recorder.currentTask);

  TaskListViewModel get taskListViewModel => TaskListViewModel(
        tasks: _recorder.tasks.where((t) => t.id != currentTaskId).toList(),
        startTask: (id) => repo.recordStartTimeOfTask(_recorder, id),
        suspendTask: (id) => repo.recordSuspendTimeOfTask(_recorder, id),
        resumeTask: (id) => repo.recordResumeTimeOfTask(_recorder, id),
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

  List<TaskListItemViewModel> get taskListItemViewModels => tasks
      .map((task) => TaskListItemViewModel(
          task: task,
          startTask: startTask,
          suspendTask: suspendTask,
          resumeTask: resumeTask))
      .toList();
}

class TaskListItemViewModel {
  TaskListItemViewModel({
    required this.task,
    required this.startTask,
    required this.suspendTask,
    required this.resumeTask,
  });

  final Task task;
  final _RecordTaskFunc startTask;
  final _RecordTaskFunc suspendTask;
  final _RecordTaskFunc resumeTask;

  String get title => task.title;
  String get startTime =>
      task.isStarted ? _dateFormat.format(task.startTime) : '-';

  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
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

  bool get isActionStart => !task.isWorking;

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
    await startTask(task.id);
  }

  Future<void> _handleSuspend() async {
    await suspendTask(task.id);
  }

  Future<void> _handleResume() async {
    await resumeTask(task.id);
  }
}
