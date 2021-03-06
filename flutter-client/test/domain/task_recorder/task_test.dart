import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/domain/task_recorder/task.dart';

void main() {
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
    });

    group('.start', () {
      final source = Task.create(title: 'some task');

      final time = DateTime.now();
      final actual = source.start(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('timeRecords に WorkTime が追加されていること', () {
        expect(actual.timeRecords.length, source.timeRecords.length + 1);
      });
      test('追加された WorkTime の start が引数の [time] であること', () {
        expect(actual.timeRecords.last.start, time);
      });

      test('既に開始済みの場合は StateError を throw すること', () {
        final started = source.start(time);
        expect(() => started.start(DateTime.now()), throwsA(isStateError));
      });
    });

    group('.suspend', () {
      final source = Task.create(title: 'some task').start(DateTime.now());

      final time = DateTime.now();
      final actual = source.suspend(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('timeRecords の個数が変更されないこと', () {
        expect(actual.timeRecords.length, source.timeRecords.length);
      });
      test('timeRecords の最後の要素の end が引数の time になること', () {
        expect(actual.timeRecords.last.end, time);
      });

      test('既に停止中の場合は StateError を throw すること', () {
        final suspended = source.suspend(time);
        expect(() => suspended.suspend(DateTime.now()), throwsA(isStateError));
      });
    });

    group('.resume', () {
      final source = Task.create(title: 'some task')
          .start(DateTime.now())
          .suspend(DateTime.now());

      final time = DateTime.now();
      final actual = source.resume(time);

      test('id, title が変更されないこと', () {
        expect(actual.id, source.id);
        expect(actual.title, source.title);
      });
      test('timeRecords に WorkTime が追加されていること', () {
        expect(actual.timeRecords.length, source.timeRecords.length + 1);
      });
      test('追加された WorkTime の start が引数の time になること', () {
        expect(actual.timeRecords.last.start, time);
      });
      test('既に作業中の場合は StateError を throw すること', () {
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
        final resumed = started.suspend(DateTime.now()).resume(DateTime.now());

        expect(started.isWorking, true);
        expect(resumed.isWorking, true);
      });

      test('作業中でない場合は false を返すこと', () {
        final unstarted = Task.create(title: 'some task');
        final suspended =
            unstarted.start(DateTime.now()).suspend(DateTime.now());

        expect(unstarted.isWorking, false);
        expect(suspended.isWorking, false);
      });
    });
  });
}
