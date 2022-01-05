import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart' as iterables;
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/work_time.dart';
import 'package:workrec_app/widgets/components.dart';

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
          appBar: AppBar(title: const Text('WorkTime List')),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: model.rows
                      .map((row) => _WorkTimeRow(viewModel: row))
                      .toList(),
                ),
        );
      }),
    );
  }
}

class _WorkTimeRow extends StatelessWidget {
  final _RowViewModelNotifier viewModel;

  const _WorkTimeRow({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<_RowViewModelNotifier, _RowViewModel>.value(
      value: viewModel,
      child: Builder(builder: (context) {
        final model = context.watch<_RowViewModel>();

        return Row(children: [
          DateTimeInput(
            initialDateTime: model.start,
            firstDateTime: model.prevEnd,
            lastDateTime: model.end ?? model.nextStart,
            onChanged: viewModel.onChangedStart,
          ),
          const Text('~'),
          DateTimeInput(
            initialDateTime: model.end ?? model.start,
            firstDateTime: model.start,
            lastDateTime: model.nextStart,
            onChanged: viewModel.onChangedEnd,
          ),
          if (model.hasChange)
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => viewModel.onSave(),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ]);
      }),
    );
  }
}

class ViewModelNotifier extends StateNotifier<ViewModel> {
  final WorkrecClient client;
  final String taskId;

  ViewModelNotifier({required this.client, required this.taskId})
      : super(ViewModel(
            isLoading: true, workTimeList: [], save: (_, __, ___) async {})) {
    client.getWorkTimeListByTaskId(taskId).then((workTimeList) {
      state = ViewModel(
        workTimeList: workTimeList,
        save: (workTime, start, end) => client.updateWorkTime(
          taskId,
          workTime,
          start: start,
          end: end,
        ),
      );
    });
  }
}

typedef _SaveFunc = Future<void> Function(WorkTime, DateTime?, DateTime?);

class ViewModel {
  final bool isLoading;
  final List<WorkTime> workTimeList;
  final _SaveFunc save;

  @visibleForTesting
  ViewModel({
    required this.workTimeList,
    required this.save,
    this.isLoading = false,
  });

  List<_RowViewModelNotifier> get rows =>
      iterables.enumerate(workTimeList).map((indexedWorkTime) {
        final workTime = indexedWorkTime.value;
        final i = indexedWorkTime.index;
        final isFirst = i == 0;
        final isLast = i == workTimeList.length - 1;

        return _RowViewModelNotifier(
          start: workTime.start,
          end: workTime.hasEnd ? workTime.end : null,
          prevEnd: isFirst ? DateTime(2000, 1, 1) : workTimeList[i - 1].end,
          nextStart:
              isLast ? DateTime(2999, 12, 31) : workTimeList[i + 1].start,
          save: (start, end) => save(workTime, start, end),
        );
      }).toList();
}

class _RowViewModelNotifier extends StateNotifier<_RowViewModel> {
  final DateTime start;
  final DateTime? end;
  final DateTime prevEnd;
  final DateTime nextStart;
  final Future<void> Function(DateTime, DateTime?) save;

  _RowViewModelNotifier({
    required this.start,
    required this.end,
    required this.prevEnd,
    required this.nextStart,
    required this.save,
  }) : super(_RowViewModel(
          start: start,
          end: end,
          prevEnd: prevEnd,
          nextStart: nextStart,
        ));

  void onChangedStart(DateTime start) {
    final hasChange =
        !this.start.isAtSameMomentAs(start) || !_equalEnd(end, state.end);
    state = _RowViewModel(
      start: start,
      end: state.end,
      prevEnd: prevEnd,
      nextStart: nextStart,
      hasChange: hasChange,
    );
  }

  void onChangedEnd(DateTime end) {
    final hasChange =
        !start.isAtSameMomentAs(state.start) || !_equalEnd(this.end, end);
    state = _RowViewModel(
      start: state.start,
      end: end,
      prevEnd: prevEnd,
      nextStart: nextStart,
      hasChange: hasChange,
    );
  }

  void onSave() async {
    await save(state.start, state.end);
    state = _RowViewModel(
      start: state.start,
      end: state.end,
      prevEnd: prevEnd,
      nextStart: nextStart,
      hasChange: false,
    );
  }

  bool _equalEnd(DateTime? lhs, DateTime? rhs) {
    final zero = DateTime.fromMillisecondsSinceEpoch(0);
    return (lhs ?? zero).isAtSameMomentAs((rhs ?? zero));
  }
}

class _RowViewModel {
  final DateTime start;
  final DateTime? end;
  final DateTime prevEnd;
  final DateTime nextStart;
  final bool hasChange;

  _RowViewModel({
    required this.start,
    required this.end,
    required this.prevEnd,
    required this.nextStart,
    this.hasChange = false,
  });
}
