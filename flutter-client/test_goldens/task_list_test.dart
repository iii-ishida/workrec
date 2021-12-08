import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec_app/widgets/task_list/task_list.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

import 'task_list_test.mocks.dart';

@GenerateMocks(
  [WorkrecClient],
)
void main() {
  testWidgets('Golden test', (WidgetTester tester) async {
    final client = MockWorkrecClient();
    when(client.currentTaskStream()).thenAnswer(
      (_) => Stream<Task>.fromIterable([
        _newTasks().firstWhere((task) => task.id == 'current'),
      ]),
    );
    when(client.tasksStream()).thenAnswer(
      (_) => Stream<List<Task>>.fromIterable([_newTasks()]),
    );

    await tester.pumpWidget(MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: TaskList(client: client),
    ));

    await tester.pump(Duration.zero);

    await expectLater(find.byType(TaskList), matchesGoldenFile('main.png'));
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

Task _newTask(String id, String title) => Task(
    id: id, state: TaskState.unstarted, title: title, timeRecords: const []);
