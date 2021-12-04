import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';

import 'work_time.dart';

enum TaskState {
  unknown,
  unstarted,
  started,
  suspended,
  resumed,
  finished,
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
    case 'suspended':
      return TaskState.suspended;
    case 'resumed':
      return TaskState.resumed;
    case 'finished':
      return TaskState.finished;
    case 'unknown':
      return TaskState.unknown;
    default:
      throw ArgumentError.value(from);
  }
}

/// 記録対象のタスク
class Task extends Equatable {
  /// id
  final String id;

  /// タスクのタイトル
  final String title;

  /// タスクの状態
  final TaskState state;

  /// 記録した作業時間のリスト
  final List<WorkTime> timeRecords;

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.timeRecords,
  });

  WorkTime get lastTimeRecord => timeRecords.last;

  /// 作業時間
  Duration get workingTime => timeRecords
      .where((task) => task.hasEnd)
      .fold(Duration.zero, (acc, time) => acc + time.workingTime);

  /// 現在作業中の作業時間
  Duration get currentWorkingTime =>
      isWorking ? clock.now().difference(lastTimeRecord.start) : Duration.zero;

  /// 開始している場合は true
  bool get isStarted => timeRecords.isNotEmpty;

  /// 作業中の場合は true
  bool get isWorking => timeRecords.isNotEmpty && !timeRecords.last.hasEnd;

  /// 開始日時
  DateTime get startTime {
    if (!isStarted) {
      throw StateError('unstarted');
    }
    return timeRecords.first.start;
  }

  /// [Task] 作成して返します
  factory Task.create({required String title}) {
    return Task(
      id: '',
      title: title,
      state: TaskState.unstarted,
      timeRecords: const [],
    );
  }

  /// タスクの作業開始日時を記録します
  /// 既に開始している場合は [StateError] を throw します
  Task start(DateTime startTime) {
    if (isStarted) {
      throw StateError('already started');
    }

    return _copyWith(
      state: TaskState.started,
      timeRecords: [...timeRecords, WorkTime(id: '', start: startTime)],
      updatedAt: clock.now(),
    );
  }

  /// タスクの作業中断日時を記録します
  /// 既に中断している場合は [StateError] を throw します
  Task suspend(DateTime suspendedAt) {
    if (!isWorking) {
      throw StateError('already suspend');
    }

    final lastRecord = timeRecords.last;
    return _copyWith(
      state: TaskState.suspended,
      timeRecords: [
        ...timeRecords.toList()..removeLast(),
        lastRecord.patch(end: suspendedAt)
      ],
      updatedAt: clock.now(),
    );
  }

  /// タスクの作業再開日時を記録します
  /// 既に作業中の場合は [StateError] を throw します
  Task resume(DateTime resumedAt) {
    if (isWorking) {
      throw StateError('already working');
    }

    return _copyWith(
      state: TaskState.resumed,
      timeRecords: [...timeRecords, WorkTime(id: '', start: resumedAt)],
      updatedAt: clock.now(),
    );
  }

  Task _copyWith({
    String? title,
    TaskState? state,
    List<WorkTime>? timeRecords,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      state: state ?? this.state,
      title: title ?? this.title,
      timeRecords: timeRecords ?? this.timeRecords,
    );
  }

  @override
  List<Object> get props => [id, title, state, timeRecords];
}
