import 'package:workrec/domain/task_recorder/task_recorder.dart';

abstract class TaskListRepo {
  final String userId;

  TaskListRepo({required this.userId});
  Stream<TaskRecorder> taskRecorder();
  Future<void> addNewTask(TaskRecorder recorder, String title);
  Future<void> recordStartTimeOfTask(TaskRecorder recorder, String taskId);
  Future<void> recordSuspendTimeOfTask(TaskRecorder recorder, String taskId);
  Future<void> recordResumeTimeOfTask(TaskRecorder recorder, String taskId);
}
