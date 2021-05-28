import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:workrec/domain/task_recorder/task.dart';

TaskList _taskList = TaskList.create(
  range(20).map((i) => Task.create(title: 'some task $i')).toList(),
);

final StreamController<TaskList> _controller = StreamController<TaskList>();

class InmemoryTaskRepo {
  final String userId;

  InmemoryTaskRepo({required this.userId});

  Stream<TaskList> taskList() {
    _controller.add(_taskList);
    return _controller.stream;
  }

  Future<void> addTask(String title) async {
    _taskList = _taskList.addNew(title: title);
    _controller.add(_taskList);
  }
}
