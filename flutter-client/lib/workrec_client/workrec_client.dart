import './models/task.dart';
import './repo/task_repo.dart';

class WorkrecClient {
  final TaskRepo _repo;

  WorkrecClient({required String userId}) : _repo = TaskRepo(userId: userId);

  Future<Task> findTaskById(String taskId) async {
    return _repo.findTaskById(taskId);
  }

  Stream<Task> currentTaskStream() {
    return _repo.currentTaskIdStream().asyncMap((id) async {
      return id.isNotEmpty
          ? await _repo.findTaskById(id)
          : Task.create(title: '');
    });
  }

  Stream<List<Task>> tasksStream() {
    return _repo.tasksStream().asyncMap((futures) => Future.wait(futures));
  }

  Future<void> addNewTask(
      {required String title, required String description}) async {
    return _repo.addTask(Task.create(title: title, description: description));
  }

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
}
