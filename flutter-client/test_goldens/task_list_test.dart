import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec/workrec.dart';
import 'package:workrec_app/task_list/task_list_page.dart';

import 'task_list_test.mocks.dart';

@GenerateMocks(
  [TaskRepo],
)
void main() {
  testWidgets('Golden test', (WidgetTester tester) async {
    final repo = MockTaskRepo();
    when(repo.taskRecorder()).thenAnswer(
      (_) => Stream<TaskRecorder>.fromIterable(
        [TaskRecorder(tasks: _newTasks(), currentTaskId: 'current')],
      ),
    );

    await tester.pumpWidget(MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TaskListPage(repo: repo),
    ));

    await tester.pump(Duration.zero);

    await expectLater(find.byType(TaskListPage), matchesGoldenFile('main.png'));
  });
}

List<Task> _newTasks() => [
      _newTask('fixture-task-01', 'fixture task 01')
          .start(DateTime.utc(2021, 5, 10, 10, 00))
          .suspend(DateTime.utc(2021, 5, 10, 12, 00)),
      _newTask('unstarted', 'fixture task 01'),
      _newTask('current', 'fixture task 02')
          .start(DateTime.utc(2021, 5, 11, 10, 00))
          .suspend(DateTime.utc(2021, 5, 11, 12, 00))
          .resume(DateTime.utc(2021, 5, 11, 13, 00)),
      _newTask('task-03', 'fixture task 03')
          .start(DateTime.utc(2021, 5, 13, 10, 00))
          .suspend(DateTime.utc(2021, 5, 13, 12, 30)),
      _newTask('fixture-task-04', 'fixture task 04')
          .start(DateTime.utc(2021, 5, 14, 10, 00))
          .suspend(DateTime.utc(2021, 5, 15, 12, 30)),
      _newTask('fixture-task-05', 'fixture task 05')
          .start(DateTime.utc(2021, 6, 14, 10, 00))
          .suspend(DateTime.utc(2021, 8, 14, 12, 34))
    ];

Task _newTask(String id, String title) =>
    Task(id: id, title: title, timeRecords: const []);
