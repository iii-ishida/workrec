import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';
import 'repo.dart';

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
        .map((docs) => TaskList.fromFirestoreDocs(docs));
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
  Future<void> start(Task task) {
    final data = <String, dynamic>{
      ...task.started(DateTime.now()).toFirestoreData(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return _taskCollection(userId).doc(task.id).update(data);
  }

  CollectionReference _taskCollection(String userId) =>
      _store.collection('users/$userId/tasks');
}
