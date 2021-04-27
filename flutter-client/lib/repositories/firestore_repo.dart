import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'task_repo.dart';

final _store = FirebaseFirestore.instance;

class FirestoreTaskRepo implements TaskListRepo {
  @override
  final String userId;

  FirestoreTaskRepo({required this.userId});

  @override
  Stream<TaskList> taskList() {
    return _taskCollection(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => docs.map((doc) => _taskFromDoc(doc)))
        .asyncMap((tasks) async => TaskList(await Future.wait(tasks)));
  }

  Future<Task> _taskFromDoc(QueryDocumentSnapshot doc) async {
    final workTimeSnapshot =
        await _workTimeCollection(userId, doc.id).orderBy('start').get();
    final workTimeDocs = workTimeSnapshot.docs;
    return Task.fromFirestoreDoc(doc, workTimeDocs);
  }

  @override
  Future<void> addTask(String title) {
    final data = <String, dynamic>{
      ...Task.create(title: title).toFirestoreData(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return _taskCollection(userId).add(data);
  }

  @override
  Future<void> start(Task task) async {
    final started = task.start(DateTime.now());
    final data = <String, dynamic>{
      ...started.toFirestoreData(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(started.id), data);

    final workTimeData = started.workTimeList.last.toFirestoreData();
    final workTimeDoc = _workTimeCollection(userId, started.id).doc();
    batch.set(workTimeDoc, workTimeData);

    await batch.commit();
  }

  @override
  Future<void> pause(Task task) async {
    final paused = task.pause(DateTime.now());
    final data = <String, dynamic>{
      ...paused.toFirestoreData(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(paused.id), data);

    final workTime = paused.workTimeList.last;
    final workTimeDoc = _workTimeCollection(userId, paused.id).doc(workTime.id);
    batch.update(workTimeDoc, workTime.toFirestoreData());

    await batch.commit();
  }

  @override
  Future<void> resume(Task task) async {
    final resumed = task.resume(DateTime.now());
    final data = <String, dynamic>{
      ...resumed.toFirestoreData(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(resumed.id), data);

    final workTime = resumed.workTimeList.last;
    final workTimeDoc = _workTimeCollection(userId, resumed.id).doc();
    batch.set(workTimeDoc, workTime.toFirestoreData());

    await batch.commit();
  }

  CollectionReference _taskCollection(String userId) =>
      _store.collection('users/$userId/tasks');

  CollectionReference _workTimeCollection(String userId, String taskId) =>
      _store.collection('users/$userId/tasks/$taskId/workTimes');
}