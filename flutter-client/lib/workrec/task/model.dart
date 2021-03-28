import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

class TaskList extends DelegatingList<Task> {
  final List<Task> _tasks;

  TaskList({required List<Task> tasks})
      : _tasks = List.unmodifiable(tasks.where((task) => task._isNotEmpty));

  @override
  List<Task> get delegate => _tasks;

  TaskList append(Task task) => TaskList(tasks: [..._tasks, task]);
}

enum TaskState {
  unstarted,
  started,
  paused,
  resumed,
  completed,
  unknown,
}

extension Strings on TaskState {
  String toShortString() => toString().split('.').last;
}

TaskState _stateFromShortString(String from) {
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
    default:
      return TaskState.unknown;
  }
}

final _timeZero = DateTime.fromMillisecondsSinceEpoch(0);

class WorkTimeList extends DelegatingList<WorkTime> {
  final List<WorkTime> _workTimes;

  WorkTimeList(List<WorkTime> workTimes)
      : _workTimes = List.unmodifiable(workTimes);

  factory WorkTimeList.fromFirestoreDocs(List<QueryDocumentSnapshot> docs) {
    return WorkTimeList(docs
        .map(
          (doc) => WorkTime.fromFirestoreDoc(doc),
        )
        .toList());
  }

  WorkTimeList started(DateTime time) {
    return WorkTimeList([WorkTime(id: '', start: time, end: _timeZero)]);
  }

  static final _empty = WorkTimeList([]);

  @override
  List<WorkTime> get delegate => _workTimes;
}

class WorkTime extends Equatable {
  final String id;
  final DateTime start;
  final DateTime end;

  const WorkTime({required this.id, required this.start, required this.end});

  factory WorkTime.fromFirestoreDoc(QueryDocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || doc.metadata.hasPendingWrites) {
      return WorkTime(id: '', start: _timeZero, end: _timeZero);
    }

    return WorkTime(
      id: doc.id,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return <String, dynamic>{
      'start': start,
      'end': end,
    };
  }

  WorkTime _copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return WorkTime(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  List<Object> get props => [id, start, end];

  @override
  bool get stringify => true;
}

class Task extends Equatable {
  final String id;
  final String title;
  final TaskState state;
  final WorkTimeList workTimeList;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.workTimeList,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.create({required String title}) {
    final now = DateTime.now();

    return Task(
      id: '',
      title: title,
      state: TaskState.unstarted,
      workTimeList: WorkTimeList._empty,
      createdAt: now,
      updatedAt: now,
    );
  }

  static final _emptyTask = Task(
    id: '',
    title: '',
    state: TaskState.unknown,
    workTimeList: WorkTimeList._empty,
    createdAt: _timeZero,
    updatedAt: _timeZero,
  );
  bool get _isNotEmpty => id != '';

  factory Task.fromFirestoreDoc(
      QueryDocumentSnapshot doc, List<QueryDocumentSnapshot> workTimeDocs) {
    final data = doc.data();
    if (data == null || doc.metadata.hasPendingWrites) {
      return _emptyTask;
    }

    return Task(
      id: doc.id,
      title: data['title'] as String,
      state: _stateFromShortString(data['state'] as String),
      workTimeList: WorkTimeList.fromFirestoreDocs(workTimeDocs),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

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

  Task started(DateTime startedAt) {
    return _copyWith(
      state: TaskState.started,
      workTimeList: workTimeList.started(startedAt),
    );
  }

  Task _copyWith({
    String? title,
    TaskState? state,
    WorkTimeList? workTimeList,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      state: state ?? this.state,
      workTimeList: workTimeList ?? this.workTimeList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return <String, dynamic>{
      'title': title,
      'state': state.toShortString(),
    };
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
