import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

class TaskList extends DelegatingList<Task> {
  final List<Task> _tasks;

  TaskList({required List<Task> tasks}) : _tasks = List.unmodifiable(tasks);

  @override
  List<Task> get delegate => _tasks;

  TaskList append(Task task) => TaskList(tasks: [..._tasks, task]);
}

enum State {
  unstarted,
  started,
  paused,
  resumed,
  completed,
}

class Task extends Equatable {
  final String id;
  final String title;
  final State state;
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
      state: State.unstarted,
      startedAt: _timeZero,
      createdAt: now,
      updatedAt: now,
    );
  }

  const Task({required this.id, required this.title});

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
