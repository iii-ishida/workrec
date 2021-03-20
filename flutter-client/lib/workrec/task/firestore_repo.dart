import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

final _store = FirebaseFirestore.instance;

class FirestoreTaskRepo {
  final String userId;

  FirestoreTaskRepo({required this.userId});

  Stream<TaskList> taskList() {
    return _taskCollection(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .map((docs) => TaskList.fromFirestoreDocs(docs));
  }

  Future<void> addTask(String title) {
    final Map<String, dynamic> data = <String, dynamic>{
      ...Task.create(title: title).toFirestoreData(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return _taskCollection(userId).add(data);
  }

  CollectionReference _taskCollection(String userId) =>
      _store.collection('users/$userId/tasks');
}
