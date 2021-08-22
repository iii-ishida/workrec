import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec/repository/task_recorder/firestore_repo.dart';
import 'package:workrec/workrec/models/task.dart';
import 'package:workrec/workrec/models/task_recorder.dart';

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
    const unstartedTaskId = 'unstarted-task';
    const suspendedTaskId = 'suspended-task';
    const currentTaskId = 'current-task';

    late FirestoreTaskRepo repo;
    late MockCollectionReference collection;
    late MockWriteBatch batch;
    late MockFirebaseFirestore firestore;

    late TaskRecorder recorder;

    setUp(() {
      collection = MockCollectionReference();
      batch = MockWriteBatch();
      firestore = MockFirebaseFirestore();

      when(firestore.collection(any)).thenReturn(collection);
      when(firestore.doc(any)).thenReturn(MockDocumentReference());
      when(collection.add(any))
          .thenAnswer((_) async => MockDocumentReference());
      when(collection.doc(any)).thenReturn(MockDocumentReference());
      when(firestore.batch()).thenReturn(batch);

      repo = FirestoreTaskRepo(userId: userId, store: firestore);

      recorder = TaskRecorder(
        tasks: _newTasks(currentTaskId, unstartedTaskId, suspendedTaskId),
        currentTaskId: currentTaskId,
      );
    });

    group('.addNewTask', () {
      test('作成したタスクを引数にして collection.add を実行すること', () async {
        const title = 'some title';
        await repo.addNewTask(recorder, title);

        final data = {
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(collection.add(data)).called(1);
      });
    });

    group('.recordStartTimeOfTask', () {
      test('開始したタスクと作業中タスクの updatedAt を batch.update で更新すること', () {
        repo.recordStartTimeOfTask(recorder, unstartedTaskId);

        final data = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(batch.update(any, data)).called(2);
      });

      test('開始したタスクの lastTimeRecord を引数にして batch.set を実行すること', () {
        FakeAsync().run((async) {
          repo.recordStartTimeOfTask(recorder, unstartedTaskId);

          final data = {
            'start': clock.now(),
            'end': DateTime.fromMillisecondsSinceEpoch(0),
          };

          verify(batch.set(any, data, null)).called(1);
        });
      });

      test('作業中タスクの lastTimeRecord を引数にして batch.update を実行すること', () {
        FakeAsync().run((async) {
          repo.recordStartTimeOfTask(recorder, unstartedTaskId);

          final data = {
            'start': recorder.currentTask.lastTimeRecord.start,
            'end': clock.now(),
          };

          verify(batch.update(any, data)).called(1);
        });
      });

      test('currentTaskId を引数にして batch.set を実行すること', () {
        repo.recordStartTimeOfTask(recorder, unstartedTaskId);

        final data = {
          'currentTaskId': unstartedTaskId,
        };

        verify(batch.set(any, data)).called(1);
      });
    });

    group('.recordSuspendTimeOfTask', () {
      test('停止したタスクの updatedAt が batch.update で更新されること', () {
        repo.recordSuspendTimeOfTask(recorder, currentTaskId);

        final data = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(batch.update(any, data)).called(1);
      });

      test('停止したタスクの lastTimeRecord を引数にして batch.update を実行すること', () {
        FakeAsync().run((async) {
          repo.recordSuspendTimeOfTask(recorder, currentTaskId);
          final start = recorder.currentTask.lastTimeRecord.start;

          final data = {
            'start': start,
            'end': clock.now(),
          };

          verify(batch.update(any, data)).called(1);
        });
      });
    });

    group('.recordResumeTimeOfTask', () {
      test('再開したタスクと作業中タスクの updatedAt を batch.update で更新すること', () {
        repo.recordResumeTimeOfTask(recorder, suspendedTaskId);

        final data = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        verify(batch.update(any, data)).called(2);
      });

      test('再開したタスクの lastTimeRecord を引数にして batch.set を実行すること', () {
        FakeAsync().run((async) {
          repo.recordResumeTimeOfTask(recorder, suspendedTaskId);

          final data = {
            'start': clock.now(),
            'end': DateTime.fromMillisecondsSinceEpoch(0),
          };

          verify(batch.set(any, data, null)).called(1);
        });
      });

      test('作業中タスクの lastTimeRecord を引数にして batch.update を実行すること', () {
        FakeAsync().run((async) {
          repo.recordResumeTimeOfTask(recorder, suspendedTaskId);

          final data = {
            'start': recorder.currentTask.lastTimeRecord.start,
            'end': clock.now(),
          };

          verify(batch.update(any, data)).called(1);
        });
      });

      test('currentTaskId を引数にして batch.set を実行すること', () {
        repo.recordResumeTimeOfTask(recorder, suspendedTaskId);

        final data = {
          'currentTaskId': suspendedTaskId,
        };

        verify(batch.set(any, data)).called(1);
      });
    });
  });
}

List<Task> _newTasks(
  String currentTaskId,
  String unstartedTaskId,
  String suspendedTaskId,
) =>
    [
      _newTask('fixture-task-01', 'fixture task 01')
          .start(DateTime.now())
          .suspend(DateTime.now()),
      _newTask(unstartedTaskId, 'fixture task 01'),
      _newTask(currentTaskId, 'fixture task 02')
          .start(DateTime.now())
          .suspend(DateTime.now())
          .resume(DateTime.now()),
      _newTask(suspendedTaskId, 'fixture task 03')
          .start(DateTime.now())
          .suspend(DateTime.now()),
      _newTask('fixture-task-04', 'fixture task 04')
          .start(DateTime.now())
          .suspend(DateTime.now()),
      _newTask('fixture-task-05', 'fixture task 05')
          .start(DateTime.now())
          .suspend(DateTime.now()),
    ];

Task _newTask(String id, String title) =>
    Task(id: id, title: title, timeRecords: const []);
