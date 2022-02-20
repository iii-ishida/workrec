import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart' as iterables;
import 'package:state_notifier/state_notifier.dart';

import 'package:workrec_app/workrec_client/models/models.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

typedef _AsyncCallback = Future<void> Function();
typedef _AsyncValueSetter<T> = Future<void> Function(T value);
typedef _ValueChanged<T> = void Function(T value);

Future<WorkTimeListViewModel> workTimeListFuture(
  WorkrecClient client,
  String taskId,
) {
  return client.getWorkTimeListByTaskId(taskId).then(
        (workTimeList) => WorkTimeListViewModel(
          workTimeList: workTimeList,
          saveWorkTime: (workTime) => client.updateWorkTime(taskId, workTime),
        ),
      );
}

class WorkTimeListViewModel {
  final bool isLoading;
  final List<WorkTime> workTimeList;
  final _AsyncValueSetter<WorkTime> saveWorkTime;

  WorkTimeListViewModel({
    required this.workTimeList,
    required this.saveWorkTime,
    this.isLoading = false,
  });

  static WorkTimeListViewModel loading = WorkTimeListViewModel(
    isLoading: true,
    workTimeList: [],
    saveWorkTime: (_) async {},
  );

  List<WorkTimeListItemViewModelNotifier> get rows =>
      iterables.enumerate(workTimeList).map((indexedWorkTime) {
        final workTime = indexedWorkTime.value;
        final i = indexedWorkTime.index;
        final isFirst = i == 0;
        final isLast = i == workTimeList.length - 1;

        return WorkTimeListItemViewModelNotifier(
          workTime: workTime,
          endOfPrevWorkTime: isFirst ? null : workTimeList[i - 1].end,
          startOfNextWorkTime: isLast ? null : workTimeList[i + 1].start,
          onSave: _handleSave,
        );
      }).toList();

  Future<void> _handleSave(WorkTime updated) async {
    await saveWorkTime(updated);
  }
}

class WorkTimeListItemViewModelNotifier
    extends StateNotifier<WorkTimeListItemViewModel> {
  final WorkTime workTime;
  final DateTime? endOfPrevWorkTime;
  final DateTime? startOfNextWorkTime;
  final _AsyncValueSetter<WorkTime> onSave;

  WorkTimeListItemViewModelNotifier({
    required this.workTime,
    required this.endOfPrevWorkTime,
    required this.startOfNextWorkTime,
    required this.onSave,
  }) : super(WorkTimeListItemViewModel.empty) {
    state = WorkTimeListItemViewModel(
      workTime: workTime,
      endOfPrevWorkTime: endOfPrevWorkTime,
      startOfNextWorkTime: startOfNextWorkTime,
      hasChanged: false,
      onChanged: (workTime) {
        state = state.copyWith(
          workTime: workTime,
          hasChanged: workTime != this.workTime,
        );
      },
      onSave: () => onSave(state.workTime),
    );
  }
}

class _DateTimeInputViewModel {
  final String text;
  final DateTime initialDateTime;
  final DateTime firstDateTime;
  final DateTime lastDateTime;

  _DateTimeInputViewModel({
    required this.text,
    required this.initialDateTime,
    required this.firstDateTime,
    required this.lastDateTime,
  });

  _DateTimeInputViewModel copyWith({
    String? text,
    DateTime? initialDateTime,
    DateTime? firstDateTime,
    DateTime? lastDateTime,
  }) {
    return _DateTimeInputViewModel(
      text: text ?? this.text,
      initialDateTime: initialDateTime ?? this.initialDateTime,
      firstDateTime: firstDateTime ?? this.firstDateTime,
      lastDateTime: lastDateTime ?? this.lastDateTime,
    );
  }
}

class WorkTimeListItemViewModel {
  final WorkTime workTime;
  final DateTime? endOfPrevWorkTime;
  final DateTime? startOfNextWorkTime;
  final bool hasChanged;
  final _ValueChanged<WorkTime> onChanged;
  final _AsyncCallback onSave;

  WorkTimeListItemViewModel({
    required this.workTime,
    required this.endOfPrevWorkTime,
    required this.startOfNextWorkTime,
    required this.hasChanged,
    required this.onChanged,
    required this.onSave,
  });

  static final empty = WorkTimeListItemViewModel(
    workTime: WorkTime.empty,
    endOfPrevWorkTime: null,
    startOfNextWorkTime: null,
    hasChanged: false,
    onChanged: (_) {},
    onSave: () async {},
  );

  _DateTimeInputViewModel get start => _DateTimeInputViewModel(
        text: _dateFormat.format(workTime.start),
        initialDateTime: workTime.start,
        firstDateTime: endOfPrevWorkTime ?? DateTime(2000, 1, 1),
        lastDateTime: hasEnd ? workTime.end : DateTime(2999, 12, 31),
      );

  _DateTimeInputViewModel get end => _DateTimeInputViewModel(
        text: _dateFormat.format(workTime.end),
        initialDateTime: workTime.end,
        firstDateTime: workTime.start,
        lastDateTime: startOfNextWorkTime ?? DateTime(2999, 12, 31),
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
    _AsyncCallback? onSave,
    _ValueChanged<WorkTime>? onChanged,
  }) {
    return WorkTimeListItemViewModel(
      workTime: workTime ?? this.workTime,
      endOfPrevWorkTime: endOfPrevWorkTime,
      startOfNextWorkTime: startOfNextWorkTime,
      hasChanged: hasChanged ?? this.hasChanged,
      onChanged: onChanged ?? this.onChanged,
      onSave: onSave ?? this.onSave,
    );
  }
}
