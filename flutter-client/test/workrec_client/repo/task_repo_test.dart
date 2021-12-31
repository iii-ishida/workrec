import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec_app/workrec_client/models/task.dart';
import 'package:workrec_app/workrec_client/repo/task_repo.dart';

import 'task_repo_test.mocks.dart';

@GenerateMocks(
  [
    FirebaseFirestore,
    DocumentReference,
  ],
  customMocks: [
    MockSpec<CollectionReference<Map<String, dynamic>>>(
        as: #MockCollectionReference)
  ],
)
void main() {
  group('TaskRepo', () {
    const userId = 'some-user-id';

    late TaskRepo repo;
    late MockCollectionReference collection;
    late MockFirebaseFirestore firestore;

    setUp(() {
      collection = MockCollectionReference();
      firestore = MockFirebaseFirestore();

      when(firestore.collection(any)).thenReturn(collection);
      when(firestore.doc(any)).thenReturn(MockDocumentReference());
      when(collection.add(any))
          .thenAnswer((_) async => MockDocumentReference());

      repo = TaskRepo(userId: userId, store: firestore);
    });

    group('.addNewTask', () {
      test('作成したタスクを引数にして collection.add を実行すること', () async {
        final task =
            Task.create(title: 'some title', description: 'some description');
        await repo.addTask(task);

        final data = <String, dynamic>{
          'title': task.title,
          'description': task.description,
          'state': task.state.name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(collection.add(data)).called(1);
      });
    });
  });
}
