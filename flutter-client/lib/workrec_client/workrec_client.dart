import './models/models.dart';
import './repo/repo.dart';

class WorkrecClient {
  final TaskRepo _repo;

  WorkrecClient({required String userId}) : _repo = TaskRepo(userId: userId);

  late final findTaskById = _repo.findTaskById;
  late final getWorkTimeListByTaskId = _repo.getWorkTimeListByTaskId;

  Stream<Task> currentTaskStream() {
    return _repo.currentTaskIdStream().asyncMap((id) async {
      return id.isNotEmpty
          ? await _repo.findTaskById(id)
          : Task.create(title: '');
    });
  }

  Stream<List<Task>> tasksStream() =>
      _repo.tasksStream().asyncMap((futures) => Future.wait(futures));

  Future<void> addNewTask({
    required String title,
    required String description,
    required int estimatedTime,
  }) =>
      _repo.addTask(Task.create(
        title: title,
        description: description,
        estimatedTime: estimatedTime,
      ));

  Future<void> updateTask(
    Task task, {
    String? title,
    String? description,
    int? estimatedTime,
  }) =>
      _repo.updateTask(task.edit(
        title: title,
        description: description,
        estimatedTime: estimatedTime,
      ));

  Future<void> startTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final started = task.start(timestamp);

    _repo.runInTransaction((tran) {
      tran.updateTask(started);
      tran.addWorkTime(started.id, started.lastTimeRecord);
      tran.updateCurrentTaskId(started.id);
    });
  }

  Future<void> suspendTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final suspended = task.suspend(timestamp);

    _repo.runInTransaction((tran) {
      tran.updateTask(suspended);
      tran.updateWorkTime(suspended.id, suspended.lastTimeRecord);
    });
  }

  Future<void> resumeTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final resumed = task.resume(timestamp);

    _repo.runInTransaction((tran) {
      tran.updateTask(resumed);
      tran.addWorkTime(resumed.id, resumed.lastTimeRecord);
      tran.updateCurrentTaskId(resumed.id);
    });
  }

  Future<void> updateWorkTime(String taskId, WorkTime workTime) =>
      _repo.runInTransaction((tran) {
        tran.updateWorkTime(taskId, workTime);
      });
}
