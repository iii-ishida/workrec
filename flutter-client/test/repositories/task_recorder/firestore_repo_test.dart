import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/repositories/task_recorder/firestore_repo.dart';
import 'package:workrec/domain/task_recorder/task.dart';

import 'firestore_repo_test.mocks.dart';

@GenerateMocks(
  [
    FirebaseFirestore,
    DocumentReference,
    WriteBatch,
  ],
  customMocks: [
    MockSpec<CollectionReference<Map<String, dynamic>>>(
        as: #MockCollectionReference)
  ],
)
void main() {
  group('FirestoreTaskRepo', () {
    const userId = 'some-user-id';

    late FirestoreTaskRepo repo;
    late MockCollectionReference collection;
    late MockWriteBatch batch;
    late MockFirebaseFirestore firestore;

    setUp(() {
      collection = MockCollectionReference();
      batch = MockWriteBatch();
      firestore = MockFirebaseFirestore();

      when(firestore.collection(any)).thenReturn(collection);
      when(collection.add(any))
          .thenAnswer((_) async => MockDocumentReference());
      when(collection.doc(any)).thenReturn(MockDocumentReference());
      when(firestore.batch()).thenReturn(batch);

      repo = FirestoreTaskRepo(userId: userId, store: firestore);
    });

    group('.addTask', () {
      test('collection.add が呼ばれること', () async {
        const title = 'some title';
        await repo.addTask(title);

        final data = {
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(firestore.collection('users/$userId/tasks'));
        verify(collection.add(data));
      });
    });

    group('.start', () {
      test('タスクと Task.start で追加された WorkTime が batch で更新されること', () {
        FakeAsync().run((async) {
          const task = Task(
            id: 'some-task',
            title: 'some task',
            timeRecords: [],
          );

          repo.start(task);

          final data = {
            'title': task.title,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final workTimeData = {
            'start': clock.now(),
            'end': DateTime.fromMillisecondsSinceEpoch(0),
          };

          verify(batch.update(any, data));
          verify(batch.set(any, workTimeData, null));
          verify(batch.commit());
        });
      });
    });
  });
}
