import 'dart:async';
import 'package:state_notifier/state_notifier.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/repositories/task_repo.dart';

class TaskController extends StateNotifier<TaskList> {
  TaskController(this.repo) : super(TaskList([]));

  final TaskListRepo repo;

  StreamSubscription<TaskList> listenTaskList() {
    return repo.taskList().listen((taskList) => state = taskList);
  }

  Future<void> addTask(String title) => repo.addTask(title);
  Future<void> startTask(Task task) => repo.start(task);
  Future<void> pauseTask(Task task) => repo.pause(task);
  Future<void> resumeTask(Task task) => repo.resume(task);
}
