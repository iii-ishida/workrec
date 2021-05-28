import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/work_time.dart';

void main() {
  group('TaskList', () {
    final time = DateTime.now();

    final source = TaskList('started-task', [
      Task(
        id: 'task-01',
        title: 'some task',
        state: TaskState.unstarted,
        workTimeList: WorkTimeList.empty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: 'task-02',
        title: 'some task',
        state: TaskState.unstarted,
        workTimeList: WorkTimeList.empty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: 'started-task',
        title: 'started task',
        state: TaskState.unstarted,
        workTimeList: WorkTimeList.empty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).start(DateTime.now())
    ]);

    group('.startTask', () {
      test('指定した taskId の Task を start すること', () {
        fakeAsync((async) {
          const taskId = 'task-02';
          final actual = source
              .startTask(taskId, time)
              .firstWhere((task) => task.id == taskId);

          final expected =
              source.firstWhere((task) => task.id == taskId).start(time);

          expect(actual, expected);
        });
      });

      test('作業中の Task を pause すること', () {
        fakeAsync((async) {
          const taskId = 'started-task';
          final actual = source
              .startTask('task-02', time)
              .firstWhere((task) => task.id == taskId);

          final expected =
              source.firstWhere((task) => task.id == taskId).pause(time);

          expect(actual, expected);
        });
      });
    });
  });

  group('Task', () {
    group('.create', () {
      const title = 'some task';
      final actual = Task.create(title: title);

      test('id が空文字であること', () {
        expect(actual.id, '');
      });
      test('title が引数の [title] であること', () {
        expect(actual.title, title);
      });
      test('state が unstarted であること', () {
        expect(actual.state, TaskState.unstarted);
      });
    });

    group('.start', () {
      final source = Task.create(title: 'some task');

      final time = DateTime.now();
      final actual = source.start(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('status が started であること', () {
        expect(actual.state, TaskState.started);
      });
      test('workTimeList に WorkTime が追加されていること', () {
        expect(actual.workTimeList.length, source.workTimeList.length + 1);
      });
      test('追加された WorkTime の start が引数の [time] であること', () {
        expect(actual.workTimeList.last.start, time);
      });

      test('state が unstarted でない場合は StateError を throw すること', () {
        final started = source.start(time);
        expect(() => started.start(DateTime.now()), throwsA(isStateError));
      });
    });

    group('.pause', () {
      final source = Task.create(title: 'some task').start(DateTime.now());

      final time = DateTime.now();
      final actual = source.pause(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('status が paused であること', () {
        expect(actual.state, TaskState.paused);
      });
      test('workTimeList の個数が変更されないこと', () {
        expect(actual.workTimeList.length, source.workTimeList.length);
      });
      test('workTimeList の最後の要素の end が引数の [time] であること', () {
        expect(actual.workTimeList.last.end, time);
      });

      test('state が started または resumed でない場合は StateError を throw すること', () {
        final paused = source.pause(time);
        expect(() => paused.pause(DateTime.now()), throwsA(isStateError));
      });
    });

    group('.resume', () {
      final source = Task.create(title: 'some task')
          .start(DateTime.now())
          .pause(DateTime.now());

      final time = DateTime.now();
      final actual = source.resume(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('status が resumed であること', () {
        expect(actual.state, TaskState.resumed);
      });
      test('workTimeList に WorkTime が追加されていること', () {
        expect(actual.workTimeList.length, source.workTimeList.length + 1);
      });
      test('追加された WorkTime の start が引数の [time] であること', () {
        expect(actual.workTimeList.last.start, time);
      });
      test('state が paused でない場合は StateError を throw すること', () {
        final resumed = source.resume(time);
        expect(() => resumed.resume(DateTime.now()), throwsA(isStateError));
      });
    });

    group('.startTime', () {
      test('開始済みの場合は開始時間を返すこと', () {
        final time = DateTime.now();
        final task = Task.create(title: 'some task').start(time);

        final actual = task.startTime;
        expect(actual, time);
      });

      test('開始していない場合は StateError を throw すること', () {
        final task = Task.create(title: 'some task');

        expect(() => task.startTime, throwsA(isStateError));
      });
    });

    group('.isStarted', () {
      test('開始済みの場合は true 返すこと', () {
        final task = Task.create(title: 'some task').start(DateTime.now());

        final actual = task.isStarted;
        expect(actual, true);
      });

      test('開始していない場合は false を返すこと', () {
        final task = Task.create(title: 'some task');

        final actual = task.isStarted;
        expect(actual, false);
      });
    });

    group('.isWorking', () {
      test('作業中の場合は true 返すこと', () {
        final started = Task.create(title: 'some task').start(DateTime.now());
        final resumed = started.pause(DateTime.now()).resume(DateTime.now());

        expect(started.isWorking, true);
        expect(resumed.isWorking, true);
      });

      test('作業中でない場合は false を返すこと', () {
        final unstarted = Task.create(title: 'some task');
        final paused = unstarted.start(DateTime.now()).pause(DateTime.now());

        expect(unstarted.isWorking, false);
        expect(paused.isWorking, false);
      });
    });
  });
}
