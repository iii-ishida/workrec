import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quiver/collection.dart';
import './work_time.dart';

/// [Task] の状態
enum TaskState {
  /// 未開始
  unstarted,

  /// 開始
  started,

  /// 停止
  paused,

  /// 再開
  resumed,

  /// 完了
  completed,

  /// 不明
  unknown,
}

extension Strings on TaskState {
  /// [String] に変換して返します
  String toShortString() => toString().split('.').last;
}

/// [from] を [TaskState] に変換して返します
/// [from] が不正な値の場合は [ArgumentError] を throw します
TaskState taskStateFromShortString(String from) {
  switch (from) {
    case 'unstarted':
      return TaskState.unstarted;
    case 'started':
      return TaskState.started;
    case 'paused':
      return TaskState.paused;
    case 'resumed':
      return TaskState.resumed;
    case 'completed':
      return TaskState.completed;
    case 'unknown':
      return TaskState.unknown;
    default:
      throw ArgumentError.value(from);
  }
}

/// タスク一覧
class TaskList extends DelegatingList<Task> {
  final String _currentTaskId;
  final List<Task> _tasks;

  factory TaskList.create(List<Task> tasks) => TaskList('', tasks);

  @visibleForTesting
  TaskList(this._currentTaskId, List<Task> tasks)
      : _tasks = List.unmodifiable(tasks.where((task) => task._isNotEmpty));

  /// TaskList に新しい [Task] を追加します
  TaskList addNew({required String title}) => TaskList(_currentTaskId, [
        ..._tasks,
        Task.create(title: title),
      ]);

  /// [taskId] に該当する [Task] を開始します
  /// 作業中の [Task] は停止します
  TaskList startTask(String taskId, DateTime time) {
    final tasks = _tasks.map((task) {
      if (task.id == taskId) {
        return task.start(time);
      }
      if (task.id == _currentTaskId) {
        return task.pause(time);
      }
      return task;
    }).toList();

    return TaskList(taskId, tasks);
  }

  /// [taskId] に該当する [Task] を停止します
  TaskList pauseTask(String taskId, DateTime time) {
    final tasks = _tasks.map((task) {
      if (task.id == taskId) {
        return task.pause(time);
      }
      return task;
    }).toList();

    return TaskList(_currentTaskId, tasks);
  }

  /// [taskId] に該当する [Task] を再開します
  /// 作業中の [Task] は停止します
  TaskList resumeTask(String taskId, DateTime time) {
    final tasks = _tasks.map((task) {
      if (task.id == taskId) {
        return task.resume(time);
      }
      if (task.id == _currentTaskId) {
        return task.pause(time);
      }
      return task;
    }).toList();

    return TaskList(taskId, tasks);
  }

  @override
  List<Task> get delegate => _tasks;
}

/// タスク
class Task extends Equatable {
  static final _dateTimeZero = DateTime.fromMillisecondsSinceEpoch(0);

  /// id
  final String id;

  /// タイトル
  final String title;

  /// タスクの状態
  final TaskState state;

  /// 作業時間一覧
  final WorkTimeList workTimeList;

  /// 作成日時
  final DateTime createdAt;

  /// 更新日時
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.workTimeList,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = Task(
    id: '',
    title: '',
    state: TaskState.unknown,
    workTimeList: WorkTimeList.empty,
    createdAt: _dateTimeZero,
    updatedAt: _dateTimeZero,
  );

  /// 作業時間
  Duration get workingTime => workTimeList.workingTime;

  /// 開始している場合は true を返します
  bool get isStarted =>
      state != TaskState.unknown && state != TaskState.unstarted;

  /// 作業中の場合は true を返します
  bool get isWorking =>
      state == TaskState.started || state == TaskState.resumed;

  /// 開始日時
  DateTime get startTime {
    if (!isStarted) {
      throw StateError('unstarted');
    }
    return workTimeList.first.start;
  }

  /// 初期状態の [Task] を返します
  factory Task.create({required String title}) {
    final now = clock.now();

    return Task(
      id: '',
      title: title,
      state: TaskState.unstarted,
      workTimeList: WorkTimeList.empty,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 次の状態を返します
  TaskState get nextState {
    switch (state) {
      case TaskState.unstarted:
        return TaskState.started;
      case TaskState.started:
        return TaskState.paused;
      case TaskState.paused:
        return TaskState.resumed;
      case TaskState.resumed:
        return TaskState.paused;
      default:
        return TaskState.unknown;
    }
  }

  /// Task を開始して返します
  /// 既に開始している場合は [StateError] を throw します
  Task start(DateTime startTime) {
    if (state != TaskState.unstarted) {
      throw StateError('already started');
    }

    return _copyWith(
      state: TaskState.started,
      workTimeList: workTimeList.started(startTime),
      updatedAt: clock.now(),
    );
  }

  /// Task を停止して返します
  /// 既に停止している場合は [StateError] を throw します
  Task pause(DateTime pausedAt) {
    if (state != TaskState.started && state != TaskState.resumed) {
      throw StateError('already paused');
    }

    return _copyWith(
      state: TaskState.paused,
      workTimeList: workTimeList.paused(pausedAt),
      updatedAt: clock.now(),
    );
  }

  /// Task を再開して返します
  /// 既に作業中の場合は [StateError] を throw します
  Task resume(DateTime resumedAt) {
    if (state != TaskState.paused) {
      throw StateError('already working');
    }

    return _copyWith(
      state: TaskState.resumed,
      workTimeList: workTimeList.resumed(resumedAt),
      updatedAt: clock.now(),
    );
  }

  bool get _isNotEmpty => id != '';

  Task _copyWith({
    String? title,
    TaskState? state,
    WorkTimeList? workTimeList,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      state: state ?? this.state,
      workTimeList: workTimeList ?? this.workTimeList,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        state,
        workTimeList,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
