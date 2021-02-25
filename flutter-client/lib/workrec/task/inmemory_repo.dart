import 'dart:async';

import 'package:quiver/iterables.dart';

import 'model.dart';

TaskList _taskList = TaskList(
  tasks: range(20).map((i) => Task(id: '$i', title: 'some task $i')).toList(),
);

final StreamController<TaskList> _controller = StreamController<TaskList>();

class InmemoryTaskRepo {
  Stream<TaskList> taskList(String userId) {
    _controller.add(_taskList);
    return _controller.stream;
  }

  Future<void> addTask(String title) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _taskList = _taskList.append(Task(id: id, title: title));
    _controller.add(_taskList);
  }
}
