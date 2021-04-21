import 'package:state_notifier/state_notifier.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/repositories/task_repo.dart';

class App extends StateNotifier<TaskList> {
  App(this.repo): super(TaskList([])) {
    watchTaskList();
  }

  final TaskListRepo repo;

  void watchTaskList() {
    repo.taskList().listen((taskList) => state = taskList);
  }

  Future<void> addTask(String title) => repo.addTask(title);
  Future<void> startTask(Task task) => repo.start(task);
  Future<void> pauseTask(Task task) => repo.pause(task);
  Future<void> resumeTask(Task task) => repo.resume(task);
}
