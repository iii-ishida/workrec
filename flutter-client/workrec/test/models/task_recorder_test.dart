import 'package:test/test.dart';
import 'package:workrec/src/models/models.dart';

void main() {
  group('TaskRecorder', () {
    late TaskRecorder recorder;

    const unstartedTaskId = 'unstarted-task';
    const currentTaskId = 'current-task';
    final tasks = _newTasks(currentTaskId, unstartedTaskId);

    setUp(() {
      recorder = TaskRecorder(tasks: tasks, currentTaskId: currentTaskId);
    });

    group('.addNewTask', () {
      test('[title] をタイトルに持つタスクが追加されること', () {
        const title = 'some title';
        final actual = recorder.addNewTask(title: title);

        expect(actual.tasks.length, tasks.length + 1);
        expect(actual.tasks.last.title, title);
      });
    });

    group('.recordStartTimeOfTask', () {
      test('[taskId] に該当するタスクの開始日時が記録されること', () {
        final timestamp = DateTime.now();

        final actual = recorder.recordStartTimeOfTask(
          unstartedTaskId,
          timestamp,
        );

        expect(_findTask(actual, unstartedTaskId).startTime, timestamp);
      });

      test('他のタスクが作業中の場合はそのタスクの停止日時が記録されること', () {
        final timestamp = DateTime.now();

        final started =
            recorder.recordStartTimeOfTask(unstartedTaskId, timestamp);
        final actual = _findTask(started, currentTaskId).timeRecords.last.end;
        expect(actual, timestamp);
      });
      test('[taskId] に該当するタスクが記録中のタスクとして設定されること', () {});
    });

    group('.recordSuspendTimeOfTask', () {
      test('[taskId] に該当するタスクの停止日時が記録されること', () {});
    });

    group('.recordResumeTimeOfTask', () {
      test('[taskId] に該当するタスクの再開日時が記録されること', () {});
      test('他のタスクが作業中の場合はそのタスクの停止日時が記録されること', () {});
      test('[taskId] に該当するタスクが記録中のタスクとして設定されること', () {});
    });

    group('.recordCompletionTimeOfTask', () {
      test('[taskId] に該当するタスクの完了日時が記録されること', () {});
    });
  });
}

List<Task> _newTasks(String currentTaskId, String unstartedTaskId) => [
      _newTask('fixture-task-01', 'fixture task 01')
          .start(DateTime.now())
          .suspend(DateTime.now()),
      _newTask(unstartedTaskId, 'fixture task 01'),
      _newTask(currentTaskId, 'fixture task 02')
          .start(DateTime.now())
          .suspend(DateTime.now())
          .resume(DateTime.now()),
      _newTask('fixture-task-03', 'fixture task 03')
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

Task _findTask(TaskRecorder recorder, String taskId) =>
    recorder.tasks.firstWhere((task) => task.id == taskId);
