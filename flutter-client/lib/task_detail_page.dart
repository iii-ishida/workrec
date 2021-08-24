import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskRepo repo;
  final String taskId;

  const TaskDetailPage({
    Key? key,
    required this.repo,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskDetailPageViewModel>(
      create: (_) => TaskDetailPageViewModel(
        repo: repo,
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
  final TaskRepo repo;
  final String taskId;
  Task? _task;

  TaskDetailPageViewModel({required this.repo, required this.taskId});

  void listen() {
    repo.findTaskById(taskId).then((task) {
      _task = task;
      notifyListeners();
    });
  }

  String get title => _task?.title ?? '';
}
