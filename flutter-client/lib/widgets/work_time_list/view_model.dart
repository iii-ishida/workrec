import 'package:flutter/material.dart' show ValueChanged;

import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart' as iterables;
import 'package:state_notifier/state_notifier.dart';

import 'package:workrec_app/workrec_client/models/models.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

class WorkTimeListViewModelNotifier
    extends StateNotifier<WorkTimeListViewModel> {
  final WorkrecClient client;
  final String taskId;

  WorkTimeListViewModelNotifier({required this.client, required this.taskId})
      : super(WorkTimeListViewModel(
            isLoading: true, workTimeList: [], save: (_) async {})) {
    client.getWorkTimeListByTaskId(taskId).then((workTimeList) {
      state = WorkTimeListViewModel(
        workTimeList: workTimeList,
        save: (workTime) => client.updateWorkTime(
          taskId,
          workTime,
        ),
      );
    });
  }
}

typedef _SaveFunc = Future<void> Function(WorkTime);

class WorkTimeListViewModel {
  final bool isLoading;
  final List<WorkTime> workTimeList;
  final _SaveFunc save;

  WorkTimeListViewModel({
    required this.workTimeList,
    required this.save,
    this.isLoading = false,
  });

  List<WorkTimeListItemViewModelNotifier> get rows =>
      iterables.enumerate(workTimeList).map((indexedWorkTime) {
        final workTime = indexedWorkTime.value;
        final i = indexedWorkTime.index;
        final isFirst = i == 0;
        final isLast = i == workTimeList.length - 1;

        return WorkTimeListItemViewModelNotifier(
          workTime: workTime,
          prevEnd: isFirst ? null : workTimeList[i - 1].end,
          nextStart: isLast ? null : workTimeList[i + 1].start,
          onSave: (updated) => save(updated),
        );
      }).toList();
}

class WorkTimeListItemViewModelNotifier
    extends StateNotifier<WorkTimeListItemViewModel> {
  final DateTime? prevEnd;
  final DateTime? nextStart;
  final WorkTime workTime;
  final Future<void> Function(WorkTime) onSave;

  WorkTimeListItemViewModelNotifier({
    required this.workTime,
    required this.prevEnd,
    required this.nextStart,
    required this.onSave,
  }) : super(
          WorkTimeListItemViewModel(
            workTime: workTime,
            prevEnd: prevEnd,
            nextStart: nextStart,
            hasChanged: false,
            onChanged: (_) {},
            onSave: () async {},
          ),
        ) {
    state = state.copyWith(
      workTime: state.workTime,
      onChanged: _handleChanged,
      onSave: () => onSave(state.workTime),
    );
  }

  void _handleChanged(WorkTime workTime) {
    state = state.copyWith(
      workTime: workTime,
      hasChanged: workTime != this.workTime,
    );
  }
}

class _Item {
  final String text;
  final DateTime value;
  final DateTime min;
  final DateTime max;

  _Item({
    required this.text,
    required this.value,
    required this.min,
    required this.max,
  });

  _Item copyWith({
    String? text,
    DateTime? value,
    DateTime? min,
    DateTime? max,
  }) {
    return _Item(
      text: text ?? this.text,
      value: value ?? this.value,
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}

class WorkTimeListItemViewModel {
  final WorkTime workTime;
  final DateTime? prevEnd;
  final DateTime? nextStart;
  final bool hasChanged;
  final ValueChanged<WorkTime> onChanged;
  final Future<void> Function() onSave;

  WorkTimeListItemViewModel({
    required this.workTime,
    required this.prevEnd,
    required this.nextStart,
    required this.hasChanged,
    required this.onChanged,
    required this.onSave,
  });

  _Item get start => _Item(
        text: _dateFormat.format(workTime.start),
        value: workTime.start,
        min: prevEnd ?? DateTime(2000, 1, 1),
        max: hasEnd ? workTime.end : DateTime(2999, 12, 31),
      );

  _Item get end => _Item(
        text: _dateFormat.format(workTime.end),
        value: workTime.end,
        min: workTime.start,
        max: nextStart ?? DateTime(2999, 12, 31),
      );

  bool get hasEnd => workTime.hasEnd;

  void onChangeStart(DateTime start) {
    onChanged(workTime.patch(start: start));
  }

  void onChangeEnd(DateTime end) {
    onChanged(workTime.patch(end: end));
  }

  WorkTimeListItemViewModel copyWith({
    WorkTime? workTime,
    bool? hasChanged,
    Future<void> Function()? onSave,
    ValueChanged<WorkTime>? onChanged,
  }) {
    return WorkTimeListItemViewModel(
      workTime: workTime ?? this.workTime,
      prevEnd: prevEnd,
      nextStart: nextStart,
      hasChanged: hasChanged ?? this.hasChanged,
      onChanged: onChanged ?? this.onChanged,
      onSave: onSave ?? this.onSave,
    );
  }
}
