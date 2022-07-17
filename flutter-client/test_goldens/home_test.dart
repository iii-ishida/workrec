import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workrec/widgets/home.dart';

void main() {
  testWidgets('Golden test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      title: 'Workrec',
      debugShowCheckedModeBanner: false,
      home: Home(),
    ));

    await tester.pump(Duration.zero);

    await expectLater(find.byType(Home), matchesGoldenFile('home.png'));
  });
}

