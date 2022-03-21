import 'package:clock/clock.dart';
import 'package:intl/intl.dart';

import 'package:workrec_app/workrec_client/models/models.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

Stream<TaskListViewModel> taskListViewModelStream(WorkrecClient client) {
  Future<void> handleToggle(Task task) async {
    if (!task.isStarted) {
      return await client.startTask(task.id, clock.now());
    }
    if (task.isWorking) {
      return await client.suspendTask(task.id, clock.now());
    } else {
      return await client.resumeTask(task.id, clock.now());
    }
  }

  return client.tasksStream().map(
        (tasks) => TaskListViewModel(
          isLoading: false,
          rows: tasks
              .map(
                (task) => TaskListItemViewModel.fromTask(
                  task: task,
                  onToggle: () => handleToggle(task),
                ),
              )
              .toList(),
        ),
      );
}

class TaskListViewModel {
  final bool isLoading;
  final List<TaskListItemViewModel> rows;

  TaskListViewModel({
    required this.isLoading,
    required this.rows,
  });

  static TaskListViewModel loading = TaskListViewModel(
    isLoading: true,
    rows: [],
  );

  void onChangeSearchText(String searchTest) {}
}

enum ToggleAction {
  start,
  suspend,
  resume,
}

class TaskListItemViewModel {
  TaskListItemViewModel({
    required this.taskId,
    required this.title,
    required this.description,
    required Duration estimatedTime,
    required Duration workingTime,
    required DateTime? startTime,
    required this.toggleAction,
    required this.onToggle,
  })  : _estimatedTime = estimatedTime,
        _workingTime = workingTime,
        _startTime = startTime;

  factory TaskListItemViewModel.fromTask({
    required Task task,
    required Future<void> Function() onToggle,
  }) {
    ToggleAction toggleAction(Task task) {
      if (!task.isStarted) {
        return ToggleAction.start;
      } else if (task.isWorking) {
        return ToggleAction.suspend;
      } else {
        return ToggleAction.resume;
      }
    }

    return TaskListItemViewModel(
      taskId: task.id,
      title: task.title,
      description: task.description,
      estimatedTime: Duration(minutes: task.estimatedTime),
      workingTime: task.workingTime,
      startTime: task.isStarted ? task.startTime : null,
      toggleAction: toggleAction(task),
      onToggle: onToggle,
    );
  }

  final Future<void> Function() onToggle;

  /// タスクのID
  final String taskId;

  /// タイトル
  final String title;

  /// 説明
  final String description;

  /// 見積もり時間
  final Duration _estimatedTime;
  String get estimatedTime => _estimatedTime.inMinutes.toString();

  /// 開始日時
  final DateTime? _startTime;
  String get startTime =>
      _startTime != null ? _dateFormat.format(_startTime!) : '-';

  /// 作業時間
  final Duration _workingTime;
  String get workingTime {
    final workingMinutes = _workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

  /// 次のアクション
  /// 開始, 停止 or 再開
  final ToggleAction toggleAction;
}
