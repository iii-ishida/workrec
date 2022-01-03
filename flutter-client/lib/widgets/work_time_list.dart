import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/work_time.dart';

class WorkTimeList extends StatelessWidget {
  final String taskId;
  const WorkTimeList({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _WorkTimeList(client: WorkrecClient(userId: userId), taskId: taskId);
  }
}

class _WorkTimeList extends StatelessWidget {
  final WorkrecClient client;
  final String taskId;

  const _WorkTimeList({
    Key? key,
    required this.client,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<ViewModelNotifier, ViewModel>(
      create: (_) => ViewModelNotifier(client: client, taskId: taskId),
      child: Builder(builder: (context) {
        final model = context.watch<ViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('WorkTime List'),
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
              : Column(
                  children: model.rows
                      .map((row) => _WorkTimeRow(
                            start: row.start,
                            end: row.end,
                          ))
                      .toList(),
                ),
        );
      }),
    );
  }
}

class _WorkTimeRow extends StatelessWidget {
  final String start;
  final String end;

  const _WorkTimeRow({
    Key? key,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(start),
      const Text('~'),
      Text(end),
    ]);
  }
}

class ViewModelNotifier extends StateNotifier<ViewModel> {
  final WorkrecClient client;
  final String taskId;

  ViewModelNotifier({
    required this.client,
    required this.taskId,
  }) : super(ViewModel(isLoading: true, workTimeList: [])) {
    client
        .getWorkTimeListByTaskId(taskId)
        .then((workTimeList) => state = ViewModel(workTimeList: workTimeList));
  }
}

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class ViewModel {
  final bool isLoading;
  final List<WorkTime> workTimeList;

  @visibleForTesting
  ViewModel({required this.workTimeList, this.isLoading = false});

  List<_ItemViewModel> get rows => workTimeList
      .map(
        (workTime) => _ItemViewModel(
          start: _dateFormat.format(workTime.start),
          end: workTime.hasEnd ? _dateFormat.format(workTime.end) : '-',
        ),
      )
      .toList();
}

class _ItemViewModel {
  final String start;
  final String end;

  const _ItemViewModel({required this.start, required this.end});
}
