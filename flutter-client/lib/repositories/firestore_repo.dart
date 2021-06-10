import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'firestore_converter.dart';
import 'task_repo.dart';

typedef QueryDocument = QueryDocumentSnapshot<Map<String, dynamic>>;

final _store = FirebaseFirestore.instance;

class FirestoreTaskRepo implements TaskListRepo {
  @override
  final String userId;

  FirestoreTaskRepo({required this.userId});

  @override
  Stream<List<Task>> taskList() {
    return _taskCollection(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => docs.map((doc) => _taskFromDoc(doc as QueryDocument)))
        .asyncMap((tasks) async => await Future.wait(tasks));
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
  Future<void> addTask(String title) {
    final data = taskToFirestoreData(
      Task.create(title: title),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    );

    return _taskCollection(userId).add(data);
  }

  @override
  Future<void> start(Task task) async {
    final started = task.start(DateTime.now());
    final data = taskToFirestoreData(
      started,
      updatedAt: FieldValue.serverTimestamp(),
    );

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(started.id), data);

    final workTimeData = workTimeToFirestoreData(started.timeRecords.last);
    final workTimeDoc = _workTimeCollection(userId, started.id).doc();
    batch.set(workTimeDoc, workTimeData);

    await batch.commit();
  }

  @override
  Future<void> suspend(Task task) async {
    final suspended = task.suspend(DateTime.now());
    final data = taskToFirestoreData(
      suspended,
      updatedAt: FieldValue.serverTimestamp(),
    );

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(suspended.id), data);

    final workTime = suspended.timeRecords.last;
    final workTimeDoc =
        _workTimeCollection(userId, suspended.id).doc(workTime.id);
    batch.update(workTimeDoc, workTimeToFirestoreData(workTime));

    await batch.commit();
  }

  @override
  Future<void> resume(Task task) async {
    final resumed = task.resume(DateTime.now());
    final data = taskToFirestoreData(
      resumed,
      updatedAt: FieldValue.serverTimestamp(),
    );

    final batch = _store.batch();
    batch.update(_taskCollection(userId).doc(resumed.id), data);

    final workTime = resumed.timeRecords.last;
    final workTimeDoc = _workTimeCollection(userId, resumed.id).doc();
    batch.set(workTimeDoc, workTimeToFirestoreData(workTime));

    await batch.commit();
  }

  CollectionReference _taskCollection(String userId) =>
      _store.collection('users/$userId/tasks');

  CollectionReference _workTimeCollection(String userId, String taskId) =>
      _store.collection('users/$userId/tasks/$taskId/workTimes');
}
