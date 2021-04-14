import 'models/task.dart';

abstract class TaskListRepo {
  final String userId;

  TaskListRepo({required this.userId});
  Stream<TaskList> taskList();
  Future<void> addTask(String title);
  Future<void> start(Task task);
  Future<void> pause(Task task);
  Future<void> resume(Task task);
}
