import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workrec/widgets/task_list.dart';

void main() {
  testWidgets('Golden test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      title: 'Workrec',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: TaskListPage()),
    ));

    await tester.pump(Duration.zero);

    await expectLater(find.byType(TaskListPage), matchesGoldenFile('task_list.png'));
  });
}
