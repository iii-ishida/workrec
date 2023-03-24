import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workrec/page/task_list.dart';

void main() {
  group('TaskListScreen', () {
    testWidgets('初期表示', (tester) async {
      await _pumpTaskList(tester);

      await tester.pump(Duration.zero);

      await expectLater(
        find.byType(TaskListScreen),
        matchesGoldenFile('task_list.png'),
      );
    });

    testWidgets('スクロール時', (tester) async {
      await _pumpTaskList(tester);

      final gesture = await tester.startGesture(const Offset(0, 500));
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskListScreen),
        matchesGoldenFile('task_list_scrolled.png'),
      );
    });
  });
}

Future<void> _pumpTaskList(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    title: 'Workrec',
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: TaskListPage()),
  ));
}
