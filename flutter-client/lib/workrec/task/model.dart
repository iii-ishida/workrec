import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

class TaskList extends DelegatingList<Task> {
  final List<Task> _tasks;

  TaskList({required List<Task> tasks}) : _tasks = List.unmodifiable(tasks);

  factory TaskList.fromFirestoreDocs(List<QueryDocumentSnapshot> docs) {
    return TaskList(
      tasks: docs
          .map((doc) => Task.fromFirestoreDoc(doc))
          .where((task) => task._isNotEmpty)
          .toList(),
    );
  }

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

class Task extends Equatable {
  final String id;
  final String title;
  final TaskState state;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final _timeZero = DateTime.fromMillisecondsSinceEpoch(0);

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.create({required String title}) {
    final now = DateTime.now();

    return Task(
      id: '',
      title: title,
      state: TaskState.unstarted,
      startedAt: _timeZero,
      createdAt: now,
      updatedAt: now,
    );
  }

  static final _emptyTask = Task(
    id: '',
    title: '',
    state: TaskState.unknown,
    startedAt: _timeZero,
    createdAt: _timeZero,
    updatedAt: _timeZero,
  );
  bool get _isNotEmpty => id != '';

  factory Task.fromFirestoreDoc(QueryDocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || doc.metadata.hasPendingWrites) {
      return _emptyTask;
    }

    return Task(
      id: doc.id,
      title: data['title'] as String,
      state: _stateFromShortString(data['state'] as String),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
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
    return _copyWith(state: TaskState.started, startedAt: startedAt);
  }

  Task _copyWith({
    String? title,
    TaskState? state,
    DateTime? startedAt,
  }) {
    return Task(
        id: id,
        title: title ?? this.title,
        state: state ?? this.state,
        startedAt: startedAt ?? this.startedAt,
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

  Map<String, dynamic> toFirestoreData() {
    return <String, dynamic>{
      'title': title,
      'state': state.toShortString(),
      'startedAt': startedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        state,
        startedAt,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
