import './models/models.dart';
import './repo/repo.dart';

class WorkrecClient {
  final TaskRepo _taskRepo;
  final UserRepo _userRepo;

  WorkrecClient({required String userId})
      : _taskRepo = TaskRepo(userId: userId),
        _userRepo = UserRepo();

  static WorkrecClient forNotLoggedIn = WorkrecClient(userId: '');

  late final findTaskById = _taskRepo.findTaskById;
  late final getWorkTimeListByTaskId = _taskRepo.getWorkTimeListByTaskId;

  // User

  Future<void> createUser({
    required String id,
    required String email,
  }) =>
      _userRepo.createUser(User.create(
        id: id,
        email: email,
      ));

  Future<void> editUser(
    User user, {
    required String name,
  }) =>
      _userRepo.updateUser(user.edit(
        name: name,
      ));

  Future<User> findUser(
    String userId,
  ) =>
      _userRepo.findUserById(userId);

  // Task

  Stream<Task> currentTaskStream() {
    return _taskRepo.currentTaskIdStream().asyncMap((id) async {
      return id.isNotEmpty
          ? await _taskRepo.findTaskById(id)
          : Task.create(title: '');
    });
  }

  Stream<List<Task>> tasksStream() =>
      _taskRepo.tasksStream().asyncMap((futures) => Future.wait(futures));

  Future<void> addNewTask({
    required String title,
    required String description,
    required int estimatedTime,
  }) =>
      _taskRepo.addTask(Task.create(
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
      _taskRepo.updateTask(task.edit(
        title: title,
        description: description,
        estimatedTime: estimatedTime,
      ));

  Future<void> startTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final started = task.start(timestamp);

    _taskRepo.runInTransaction((tran) {
      tran.updateTask(started);
      tran.addWorkTime(started.id, started.lastTimeRecord);
      tran.updateCurrentTaskId(started.id);
    });
  }

  Future<void> suspendTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final suspended = task.suspend(timestamp);

    _taskRepo.runInTransaction((tran) {
      tran.updateTask(suspended);
      tran.updateWorkTime(suspended.id, suspended.lastTimeRecord);
    });
  }

  Future<void> resumeTask(String taskId, DateTime timestamp) async {
    final task = await findTaskById(taskId);
    final resumed = task.resume(timestamp);

    _taskRepo.runInTransaction((tran) {
      tran.updateTask(resumed);
      tran.addWorkTime(resumed.id, resumed.lastTimeRecord);
      tran.updateCurrentTaskId(resumed.id);
    });
  }

  Future<void> updateWorkTime(String taskId, WorkTime workTime) =>
      _taskRepo.runInTransaction((tran) {
        tran.updateWorkTime(taskId, workTime);
      });
}
