import 'dart:async';

import 'package:quiver/iterables.dart';

import 'model.dart';

class InmemoryTaskRepo {
  final StreamController<TaskList> _controller = StreamController<TaskList>();

  Stream<TaskList> watch(String userId) {
    _controller.add(
      TaskList(
        tasks: range(20)
            .map((i) => Task(id: '$i', title: 'some task $i'))
            .toList(),
      ),
    );

    return _controller.stream;
  }
}
