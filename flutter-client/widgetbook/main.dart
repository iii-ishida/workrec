import 'package:flutter/material.dart';

import 'widgetbook.dart';

void main() {
  runApp(const HotreloadWidgetbook());
}

class CustomWidget extends StatelessWidget {
  const CustomWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: const Text('hello world'),
    );
  }
}
