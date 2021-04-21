import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/repositories/task_repo.dart';

class App {
  App(this.repo);

  final TaskListRepo repo;

  Stream<TaskList> fetchTaskList() => repo.taskList();

  Future<void> addTask(String title) => repo.addTask(title);
  Future<void> startTask(Task task) => repo.start(task);
  Future<void> pauseTask(Task task) => repo.pause(task);
  Future<void> resumeTask(Task task) => repo.resume(task);
}
