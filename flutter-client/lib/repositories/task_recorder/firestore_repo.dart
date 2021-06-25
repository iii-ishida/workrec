import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec/domain/task_recorder/task_recorder.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/work_time.dart';
import 'package:stream_transform/stream_transform.dart';
import 'firestore_converter.dart';
import 'task_repo.dart';

typedef QueryDocument = QueryDocumentSnapshot<Map<String, dynamic>>;

class FirestoreTaskRepo implements TaskListRepo {
  @override
  final String userId;

  final FirebaseFirestore _store;

  FirestoreTaskRepo({required this.userId, FirebaseFirestore? store})
      : _store = store ?? FirebaseFirestore.instance;

  @override
  Stream<TaskRecorder> taskRecorder() {
    final tasksStream = _taskCollection(userId)
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) => docs.map((doc) => _taskFromDoc(doc as QueryDocument)))
        .asyncMap((tasks) async => await Future.wait(tasks));

    final currentTaskIdStream = _userDoc(userId).snapshots().map(
          (snapshots) => snapshots.exists
              ? (snapshots.get('currentTaskId') as String)
              : '',
        );

    return tasksStream.combineLatest(
      currentTaskIdStream,
      (tasks, currentTaskId) => TaskRecorder(
        tasks: tasks,
        currentTaskId: currentTaskId as String,
      ),
    );
  }

  Future<Task> _taskFromDoc(QueryDocument doc) async {
    final workTimeSnapshot = await _workTimeCollection(
      userId,
      doc.id,
    ).orderBy('start').get();

    final workTimeDocs = workTimeSnapshot.docs as List<QueryDocument>;
    return taskFromFirestoreDoc(doc, workTimeDocs);
  }

  @override
  Future<void> addNewTask(TaskRecorder recorder, String title) {
    final recorded = recorder.addNewTask(title: title);
    final data = taskToFirestoreData(
      task: recorded.tasks.last,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    );

    return _taskCollection(userId).add(data);
  }

  @override
  Future<void> recordStartTimeOfTask(TaskRecorder source, String taskId) async {
    final recorded = source.recordStartTimeOfTask(taskId, clock.now());
    final started = recorded.currentTask;

    final batch = _store.batch();

    _updateTask(batch, userId: userId, taskId: started.id);
    _addWorkTime(
      batch,
      userId: userId,
      taskId: started.id,
      workTime: started.lastTimeRecord,
    );

    if (taskId != source.currentTaskId) {
      _updateCurrentTaskId(
        batch,
        userId: userId,
        taskId: started.id,
      );
      if (source.currentTaskId.isNotEmpty) {
        _savePrevCurrentTask(
          batch,
          userId: userId,
          currentTask: recorded.findTask(source.currentTaskId),
        );
      }
    }

    await batch.commit();
  }

  @override
  Future<void> recordSuspendTimeOfTask(
      TaskRecorder source, String taskId) async {
    final recorded = source.recordSuspendTimeOfTask(taskId, clock.now());
    final suspended = recorded.findTask(taskId);

    final batch = _store.batch();
    _updateTask(batch, userId: userId, taskId: suspended.id);

    final workTime = suspended.timeRecords.last;
    _updateWorkTime(
      batch,
      userId: userId,
      taskId: suspended.id,
      workTime: workTime,
    );

    await batch.commit();
  }

  @override
  Future<void> recordResumeTimeOfTask(
      TaskRecorder source, String taskId) async {
    final recorded = source.recordResumeTimeOfTask(taskId, clock.now());
    final resumed = recorded.currentTask;

    final batch = _store.batch();

    _updateTask(batch, userId: userId, taskId: resumed.id);
    _addWorkTime(
      batch,
      userId: userId,
      taskId: resumed.id,
      workTime: resumed.lastTimeRecord,
    );

    if (taskId != source.currentTaskId) {
      _updateCurrentTaskId(
        batch,
        userId: userId,
        taskId: resumed.id,
      );
      if (source.currentTaskId.isNotEmpty) {
        _savePrevCurrentTask(
          batch,
          userId: userId,
          currentTask: recorded.findTask(source.currentTaskId),
        );
      }
    }

    await batch.commit();
  }

  void _savePrevCurrentTask(WriteBatch batch,
      {required String userId, required Task currentTask}) {
    _updateTask(batch, userId: userId, taskId: currentTask.id);

    final workTime = currentTask.lastTimeRecord;
    _updateWorkTime(
      batch,
      userId: userId,
      taskId: currentTask.id,
      workTime: workTime,
    );
  }

  void _updateCurrentTaskId(
    WriteBatch batch, {
    required String userId,
    required String taskId,
  }) {
    final userData = {'currentTaskId': taskId};
    batch.set(_userDoc(userId), userData);
  }

  void _updateTask(
    WriteBatch batch, {
    required String userId,
    required String taskId,
  }) {
    final taskData = taskToFirestoreData(
      updatedAt: FieldValue.serverTimestamp(),
    );
    batch.update(_taskCollection(userId).doc(taskId), taskData);
  }

  void _addWorkTime(
    WriteBatch batch, {
    required String userId,
    required String taskId,
    required WorkTime workTime,
  }) {
    final workTimeData = workTimeToFirestoreData(workTime);
    final workTimeDoc = _workTimeCollection(userId, taskId).doc();
    batch.set(workTimeDoc, workTimeData);
  }

  void _updateWorkTime(
    WriteBatch batch, {
    required String userId,
    required String taskId,
    required WorkTime workTime,
  }) {
    final workTimeDoc = _workTimeCollection(userId, taskId).doc(workTime.id);
    batch.update(workTimeDoc, workTimeToFirestoreData(workTime));
  }

  DocumentReference _userDoc(String userId) => _store.doc('users/$userId');

  CollectionReference _taskCollection(String userId) =>
      _store.collection('users/$userId/tasks');

  CollectionReference _workTimeCollection(String userId, String taskId) =>
      _store.collection('users/$userId/tasks/$taskId/workTimes');
}
