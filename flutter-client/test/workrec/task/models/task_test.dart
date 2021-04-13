import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/workrec/task/models/task.dart';

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
      test('state が unstarted であること', () {
        expect(actual.state, TaskState.unstarted);
      });
    });

    group('.started', () {
      final source = Task.create(title: 'some task');

      final time = DateTime.now();
      final actual = source.started(time);

      test('id が変更されないこと', () {
        expect(actual.id, source.id);
      });
      test('title が変更されないこと', () {
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
    });

    group('.paused', () {
      final source = Task.create(title: 'some task').started(DateTime.now());

      final time = DateTime.now();
      final actual = source.paused(time);

      test('id が変更されないこと', () {
        expect(actual.id, source.id);
      });
      test('title が変更されないこと', () {
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
    });

    group('.resumed', () {
      final source = Task.create(title: 'some task')
          .started(DateTime.now())
          .paused(DateTime.now());

      final time = DateTime.now();
      final actual = source.resumed(time);

      test('id が変更されないこと', () {
        expect(actual.id, source.id);
      });
      test('title が変更されないこと', () {
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
    });
  });
}
