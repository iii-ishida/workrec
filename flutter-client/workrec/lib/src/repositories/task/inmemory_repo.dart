import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:workrec/src/models/models.dart';

List<Task> _taskList =
    range(20).map((i) => Task.create(title: 'some task $i')).toList();

final StreamController<List<Task>> _controller = StreamController<List<Task>>();

class InmemoryTaskRepo {
  final String userId;

  InmemoryTaskRepo({required this.userId});

  Stream<List<Task>> taskList() {
    _controller.add(_taskList);
    return _controller.stream;
  }

  Future<void> addTask(String title) async {
    _taskList = [..._taskList, Task.create(title: title)];
    _controller.add(_taskList);
  }
}
