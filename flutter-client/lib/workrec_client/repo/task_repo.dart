import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec_app/workrec_client/models/task.dart';
import 'package:workrec_app/workrec_client/models/work_time.dart';

import 'firestore_converter.dart';

typedef TransactionCallback = Function(TaskTransaction);
typedef _QueryDocument = DocumentSnapshot<Map<String, dynamic>>;

class TaskRepo {
  final String userId;

  final FirebaseFirestore _store;

  TaskRepo({required this.userId, FirebaseFirestore? store})
      : _store = store ?? FirebaseFirestore.instance;

  Future<Task> findTaskById(String taskId) {
    return _taskCollection(_store, userId)
        .doc(taskId)
        .get()
        .then((doc) => _taskFromDoc(doc as _QueryDocument));
  }

  Stream<String> currentTaskIdStream() {
    return _userDoc(userId).snapshots().map(
          (snapshots) => snapshots.exists
              ? (snapshots.get('currentTaskId') as String)
              : '',
        );
  }

  Stream<List<Future<Task>>> tasksStream() {
    return _taskCollection(_store, userId)
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) =>
            docs.map((doc) => _taskFromDoc(doc as _QueryDocument)).toList());
  }

  Future<Task> _taskFromDoc(_QueryDocument doc) async {
    final workTimeSnapshot = await _workTimeCollection(
      _store,
      userId,
      doc.id,
    ).orderBy('start').get();

    final workTimeDocs = workTimeSnapshot.docs as List<_QueryDocument>;
    return taskFromFirestoreDoc(doc, workTimeDocs);
  }

  Future<void> addTask(Task task) {
    final data = taskToFirestoreData(
      task: task,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    );

    return _taskCollection(_store, userId).add(data);
  }

  Future<void> runInTransaction(TransactionCallback callback) async {
    final tran = TaskTransaction(_store, userId);
    callback(tran);

    await tran.commit();
  }

  DocumentReference _userDoc(String userId) => _store.doc('users/$userId');
}

class TaskTransaction {
  final String _userId;
  final FirebaseFirestore _store;
  final WriteBatch _batch;

  TaskTransaction(this._store, this._userId) : _batch = _store.batch();

  Future<void> commit() => _batch.commit();

  void updateTask(Task task) {
    final taskData = taskToFirestoreData(
      updatedAt: FieldValue.serverTimestamp(),
    );
    _batch.update(_taskCollection(_store, _userId).doc(task.id), taskData);
  }

  void addWorkTime(String taskId, WorkTime workTime) {
    final workTimeData = workTimeToFirestoreData(workTime);
    final workTimeDoc = _workTimeCollection(_store, _userId, taskId).doc();
    _batch.set(workTimeDoc, workTimeData);
  }

  void updateWorkTime(String taskId, WorkTime workTime) {
    final workTimeDoc =
        _workTimeCollection(_store, _userId, taskId).doc(workTime.id);
    _batch.update(workTimeDoc, workTimeToFirestoreData(workTime));
  }

  void updateCurrentTaskId(String taskId) {
    final userData = {'currentTaskId': taskId};
    _batch.set(_userDoc(_store, _userId), userData);
  }
}

DocumentReference _userDoc(FirebaseFirestore store, String userId) =>
    store.doc('users/$userId');

CollectionReference _taskCollection(FirebaseFirestore store, String userId) =>
    store.collection('users/$userId/tasks');

CollectionReference _workTimeCollection(
  FirebaseFirestore store,
  String userId,
  String taskId,
) =>
    store.collection('users/$userId/tasks/$taskId/workTimes');
