import 'model.dart';

abstract class TaskListRepo {
  final String userId;

  TaskListRepo({required this.userId});
  Stream<TaskList> taskList();
  Future<void> addTask(String title);
  Future<void> start(Task task);
}
