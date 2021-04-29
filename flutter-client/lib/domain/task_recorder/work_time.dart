import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

final _dateTimeZero = DateTime.fromMillisecondsSinceEpoch(0);

class WorkTimeList extends DelegatingList<WorkTime> {
  final List<WorkTime> _workTimes;

  WorkTimeList(List<WorkTime> workTimes)
      : _workTimes = List.unmodifiable(workTimes);

  Duration get workingTime => _workTimes.fold(
        Duration.zero,
        (acc, time) => acc + (time._endOrNow.difference(time.start)),
      );

  WorkTimeList started(DateTime time) {
    return WorkTimeList([WorkTime(id: '', start: time, end: _dateTimeZero)]);
  }

  WorkTimeList paused(DateTime time) {
    final lastWorkTime = _workTimes.last;

    return WorkTimeList([
      ..._workTimes.toList()..removeLast(),
      lastWorkTime._copyWith(end: time)
    ]);
  }

  WorkTimeList resumed(DateTime time) {
    return WorkTimeList([
      ..._workTimes,
      WorkTime(id: '', start: time, end: _dateTimeZero),
    ]);
  }

  static final empty = WorkTimeList([]);

  @override
  List<WorkTime> get delegate => _workTimes;
}

class WorkTime extends Equatable {
  final String id;
  final DateTime start;
  final DateTime end;
  DateTime get _endOrNow => end == _dateTimeZero ? DateTime.now() : end;

  const WorkTime({required this.id, required this.start, required this.end});

  static final empty = WorkTime(id: '', start: _dateTimeZero, end: DateTime(0));

  WorkTime _copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return WorkTime(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  List<Object> get props => [id, start, end];

  @override
  bool get stringify => true;
}
