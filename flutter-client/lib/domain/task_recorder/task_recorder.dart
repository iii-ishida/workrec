import './task.dart';

class TaskRecorder {
  TaskRecorder({required List<Task> tasks, required this.currentTaskId})
      : tasks = List.unmodifiable(tasks);

  /// 記録しているタスクのリスト
  final List<Task> tasks;

  /// 現在記録中のタスクのID
  final String currentTaskId;

  /// 現在記録中のタスク
  Task get currentTask => findTask(currentTaskId);

  /// タスクを追加します
  TaskRecorder addNewTask({required String title}) {
    return TaskRecorder(
      tasks: [...tasks, Task.create(title: title)],
      currentTaskId: currentTaskId,
    );
  }

  /// [taskId] に該当するタスクの作業開始日時を記録します
  TaskRecorder recordStartTimeOfTask(String taskId, DateTime timestamp) {
    final newTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.start(timestamp);
      }
      if (task.id == currentTaskId) {
        return task.suspend(timestamp);
      }
      return task;
    }).toList();

    return TaskRecorder(tasks: newTasks, currentTaskId: taskId);
  }

  /// [taskId] に該当するタスクの作業停止日時を記録します
  TaskRecorder recordSuspendTimeOfTask(String taskId, DateTime timestamp) {
    final newTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.suspend(timestamp);
      }
      return task;
    }).toList();

    return TaskRecorder(tasks: newTasks, currentTaskId: taskId);
  }

  /// [taskId] に該当するタスクの作業再開日時を記録します
  TaskRecorder recordResumeTimeOfTask(String taskId, DateTime timestamp) {
    final newTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.resume(timestamp);
      }
      if (task.id == currentTaskId) {
        return task.suspend(timestamp);
      }
      return task;
    }).toList();

    return TaskRecorder(tasks: newTasks, currentTaskId: taskId);
  }

  /// [taskId] に該当するタスクの作業完了日時を記録します
  TaskRecorder recordCompletionTimeOfTask(String taskId, DateTime timestamp) {
    return TaskRecorder(tasks: [], currentTaskId: '');
  }

  Task findTask(String taskId) => tasks.firstWhere((task) => task.id == taskId);
}
