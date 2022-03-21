import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:workrec_app/workrec_client/models/task.dart';
import 'package:workrec_app/workrec_client/repo/task_repo.dart';

// ignore_for_file: subtype_of_sealed_class

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('TaskRepo', () {
    const userId = 'some-user-id';

    late TaskRepo repo;
    late MockCollectionReference collection;
    late MockFirebaseFirestore firestore;

    setUp(() {
      collection = MockCollectionReference();
      firestore = MockFirebaseFirestore();

      when(() => firestore.collection(any())).thenReturn(collection);
      when(() => firestore.doc(any())).thenReturn(MockDocumentReference());
      when(() => collection.add(any()))
          .thenAnswer((_) async => MockDocumentReference());

      repo = TaskRepo(userId: userId, store: firestore);
    });

    group('.addNewTask', () {
      test('作成したタスクを引数にして collection.add を実行すること', () async {
        final task = Task.create(
          title: 'some title',
          description: 'some description',
          estimatedTime: 90,
        );
        await repo.addTask(task);

        final data = <String, dynamic>{
          'title': task.title,
          'description': task.description,
          'estimatedTime': task.estimatedTime,
          'state': task.state.name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(() => collection.add(data)).called(1);
      });
    });
  });
}
