import 'package:workrec/domain/task_recorder/task.dart';

abstract class TaskListRepo {
  final String userId;

  TaskListRepo({required this.userId});
  Stream<List<Task>> taskList();
  Future<void> addTask(String title);
  Future<void> start(Task task);
  Future<void> suspend(Task task);
  Future<void> resume(Task task);
}
