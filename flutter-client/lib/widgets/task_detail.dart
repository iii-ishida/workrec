import 'package:flutter/material.dart';

import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:state_notifier/state_notifier.dart';

import 'package:workrec_app/workrec_client/models/models.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

class TaskDetail extends StatelessWidget {
  final String taskId;
  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.read<WorkrecClient>();
    return _TaskDetail(client: client, taskId: taskId);
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
                  taskId: taskId,
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
  final String taskId;
  final String title;
  final String description;
  final String startTime;
  final String workingTime;
  final String estimatedTime;

  const _TaskDetailBody({
    Key? key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.workingTime,
    required this.estimatedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          TextButton(
            onPressed: () => context.push('/tasks/$taskId/work-times'),
            child: Text('作業時間一覧', style: Theme.of(context).textTheme.button),
          ),
        ],
      ),
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
