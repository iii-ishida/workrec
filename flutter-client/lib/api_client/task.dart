/// A state of a task.
enum TaskState {
  /// The task is not started.
  notStarted,

  /// The task is in progress.
  inProgress,

  /// The task is completed.
  completed,
}

/// A task is a unit of work that can be completed.
class Task {
  /// The unique identifier of the task.
  final String id;

  /// The title of the task.
  final String title;

  /// The state of the task.
  final TaskState state;

  /// The total work time of the task.
  final int totalWorkingTime;

  const Task({
    required this.id,
    required this.title,
    required this.state,
    required this.totalWorkingTime,
  });
}
