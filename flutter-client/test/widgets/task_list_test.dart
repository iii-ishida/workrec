import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:workrec_app/widgets/task_list/view_model.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

class TaskAction {
  Future<void> startTask(String _) async {}
  Future<void> suspendTask(String _) async {}
  Future<void> resumeTask(String _) async {}
}

class MockTaskAction extends Mock implements TaskAction {}

void main() {
  group('TaskListViewModel', () {
    late TaskListViewModel model;
    late MockTaskAction mock;

    setUp(() {
      mock = MockTaskAction();
      when(() => mock.startTask(any())).thenAnswer((_) async {});
      when(() => mock.suspendTask(any())).thenAnswer((_) async {});
      when(() => mock.resumeTask(any())).thenAnswer((_) async {});

      model = TaskListViewModel(
        isLoading: false,
        tasks: [
          const Task(
            id: 'some-task',
            title: 'some task',
            description: '',
            estimatedTime: 0,
            state: TaskState.unstarted,
            timeRecords: [],
          )
        ],
        startTask: mock.startTask,
        suspendTask: mock.suspendTask,
        resumeTask: mock.resumeTask,
      );
    });

    group('.onToggle', () {
      test('開始していない場合は startTask を呼ぶこと', () async {
        await model.rows[0].onToggle();
        verify(() => mock.startTask(any()));
      });
      test('開始していない場合は suspendTask を呼ばないこと', () async {
        await model.rows[0].onToggle();
        verifyNever(() => mock.suspendTask(any()));
      });
      test('開始していない場合は resumeTask を呼ばないこと', () async {
        await model.rows[0].onToggle();
        verifyNever(() => mock.resumeTask(any()));
      });
    });
  });
}