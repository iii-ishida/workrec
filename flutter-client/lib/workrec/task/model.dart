import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

class TaskList extends DelegatingList<Task> {
  final List<Task> _tasks;

  TaskList({required List<Task> tasks}) : _tasks = List.unmodifiable(tasks);

  @override
  List<Task> get delegate => _tasks;

  TaskList append(Task task) => TaskList(tasks: [..._tasks, task]);
}

class Task extends Equatable {
  final String id;
  final String title;

  const Task({required this.id, required this.title});

  @override
  List<Object> get props => [id, title];

  @override
  bool get stringify => true;
}
