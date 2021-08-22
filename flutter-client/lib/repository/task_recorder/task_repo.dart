import 'package:workrec/workrec/models/task.dart';
import 'package:workrec/workrec/models/task_recorder.dart';

abstract class TaskListRepo {
  final String userId;

  TaskListRepo({required this.userId});
  Future<Task> findTaskById(String taskId);

  Stream<TaskRecorder> taskRecorder();
  Future<void> addNewTask(TaskRecorder recorder, String title);
  Future<void> recordStartTimeOfTask(TaskRecorder recorder, String taskId);
  Future<void> recordSuspendTimeOfTask(TaskRecorder recorder, String taskId);
  Future<void> recordResumeTimeOfTask(TaskRecorder recorder, String taskId);
}
