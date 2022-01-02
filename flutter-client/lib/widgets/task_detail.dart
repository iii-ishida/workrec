import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

class TaskDetail extends StatelessWidget {
  final String taskId;
  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _TaskDetail(client: WorkrecClient(userId: userId), taskId: taskId);
  }
}

class _TaskDetail extends StatelessWidget {
  final WorkrecClient client;
  final String taskId;

  const _TaskDetail({Key? key, required this.client, required this.taskId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<ViewModelNotifier, ViewModel>(
      create: (_) => ViewModelNotifier(client: client, taskId: taskId),
      child: Builder(builder: (context) {
        final model = context.watch<ViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text(model.isLoading ? 'Detail Task' : model.title),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => context.push('/tasks/$taskId/edit'),
                child: const Text('Edit'),
              ),
            ],
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _TaskDetailBody(
                  title: model.title,
                  description: model.description,
                  startTime: model.startTime,
                  workingTime: model.workingTime,
                  estimatedTime: model.estimatedTime),
        );
      }),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String workingTime;
  final String estimatedTime;

  const _TaskDetailBody({
    Key? key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.workingTime,
    required this.estimatedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(title),
        Text(
          description,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          '開始日時: $startTime',
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          '作業時間: $workingTime',
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          '見積もり時間: $estimatedTime分',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}

class ViewModelNotifier extends StateNotifier<ViewModel> {
  final WorkrecClient client;
  final String taskId;

  ViewModelNotifier({required this.client, required this.taskId})
      : super(ViewModel(isLoading: true, task: Task.empty)) {
    client.findTaskById(taskId).then((task) => state = ViewModel(
          task: task,
        ));
  }
}

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class ViewModel {
  final bool isLoading;
  final Task task;

  @visibleForTesting
  ViewModel({required this.task, this.isLoading = false});

  String get title => task.title;

  String get description => task.description;

  String get estimatedTime => task.estimatedTime.toString();

  String get startTime =>
      task.isStarted ? _dateFormat.format(task.startTime) : '-';

  /// 作業時間
  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }
}
