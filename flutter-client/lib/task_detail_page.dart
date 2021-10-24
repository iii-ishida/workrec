import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec.dart';

class TaskDetailPage extends StatelessWidget {
  final WorkrecClient client;
  final String taskId;

  const TaskDetailPage({
    Key? key,
    required this.client,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskDetailPageViewModel>(
      create: (_) => TaskDetailPageViewModel(
        client: client,
        taskId: taskId,
      )..listen(),
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<TaskDetailPageViewModel>();
          return Scaffold(
            appBar: AppBar(title: Text(viewModel.title)),
            body: const Placeholder(),
          );
        },
      ),
    );
  }
}

class TaskDetailPageViewModel extends ChangeNotifier {
  final WorkrecClient client;
  final String taskId;
  Task? _task;

  TaskDetailPageViewModel({required this.client, required this.taskId});

  void listen() {
    client.findTaskById(taskId).then((task) {
      _task = task;
      notifyListeners();
    });
  }

  String get title => _task?.title ?? '';
}
