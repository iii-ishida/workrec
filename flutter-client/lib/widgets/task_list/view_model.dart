import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:state_notifier/state_notifier.dart';

import 'package:workrec_app/workrec_client/models/models.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

typedef _RecordTaskFunc = Future<void> Function(String);

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class TaskListViewModelNotifier extends StateNotifier<TaskListViewModel> {
  final WorkrecClient client;
  TaskListViewModelNotifier(this.client) : super(TaskListViewModel.loading) {
    client.tasksStream().listen((tasks) {
      state = TaskListViewModel(
        isLoading: false,
        tasks: tasks,
        startTask: (id) => client.startTask(id, clock.now()),
        suspendTask: (id) => client.suspendTask(id, clock.now()),
        resumeTask: (id) => client.resumeTask(id, clock.now()),
      );
    });
  }
}

class TaskListViewModel {
  final bool isLoading;

  final List<Task> tasks;
  final _RecordTaskFunc startTask;
  final _RecordTaskFunc suspendTask;
  final _RecordTaskFunc resumeTask;

  TaskListViewModel({
    required this.tasks,
    required this.startTask,
    required this.suspendTask,
    required this.resumeTask,
    required this.isLoading,
  });

  static TaskListViewModel loading = TaskListViewModel(
    isLoading: true,
    tasks: [],
    startTask: (_) async {},
    suspendTask: (_) async {},
    resumeTask: (_) async {},
  );

  void onChangeSearchText(String searchTest) {}

  List<TaskListItemViewModel> get rows => tasks
      .map(
        (task) => TaskListItemViewModel(
          task: task,
          onToggle: () async => _handleToggle(task),
        ),
      )
      .toList();

  Future<void> _handleToggle(Task task) async {
    if (!task.isStarted) {
      return await startTask(task.id);
    }
    if (task.isWorking) {
      return await suspendTask(task.id);
    } else {
      return await resumeTask(task.id);
    }
  }
}

enum ToggleAction {
  start,
  suspend,
  resume,
}

class TaskListItemViewModel {
  TaskListItemViewModel({
    required Task task,
    required this.onToggle,
  }) : _task = task;

  final Task _task;
  final Future<void> Function() onToggle;

  /// ID
  String get taskId => _task.id;

  /// タイトル
  String get title => _task.title;

  /// 説明
  String get description => _task.description;

  /// 見積もり時間
  String get estimatedTime => '${_task.estimatedTime}';

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
