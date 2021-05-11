import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';
import './work_time.dart';

enum TaskState {
  unstarted,
  started,
  paused,
  resumed,
  completed,
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

class TaskList extends DelegatingList<Task> {
  final List<Task> _tasks;

  TaskList(List<Task> tasks)
      : _tasks = List.unmodifiable(tasks.where((task) => task._isNotEmpty));

  @override
  List<Task> get delegate => _tasks;

  /// TaskList に新しい [Task] を追加します
  TaskList addNew({required String title}) => TaskList([
        ..._tasks,
        Task.create(title: title),
      ]);
}

class Task extends Equatable {
  static final _dateTimeZero = DateTime.fromMillisecondsSinceEpoch(0);

  final String id;
  final String title;
  final TaskState state;
  final WorkTimeList workTimeList;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get workingTime => workTimeList.workingTime;

  bool get isStarted =>
      state != TaskState.unknown && state != TaskState.unstarted;

  bool get isWorking =>
      state == TaskState.started || state == TaskState.resumed;

  DateTime get startTime {
    if (!isStarted) {
      throw StateError('unstarted');
    }
    return workTimeList.first.start;
  }

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.workTimeList,
    required this.createdAt,
    required this.updatedAt,
  });

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

  static final empty = Task(
    id: '',
    title: '',
    state: TaskState.unknown,
    workTimeList: WorkTimeList.empty,
    createdAt: _dateTimeZero,
    updatedAt: _dateTimeZero,
  );

  bool get _isNotEmpty => id != '';

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
