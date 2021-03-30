import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/collection.dart';

final _timeZero = DateTime.fromMillisecondsSinceEpoch(0);

class WorkTimeList extends DelegatingList<WorkTime> {
  final List<WorkTime> _workTimes;

  WorkTimeList(List<WorkTime> workTimes)
      : _workTimes = List.unmodifiable(workTimes);

  factory WorkTimeList.fromFirestoreDocs(List<QueryDocumentSnapshot> docs) {
    return WorkTimeList(docs
        .map(
          (doc) => WorkTime.fromFirestoreDoc(doc),
        )
        .toList());
  }

  Duration get workingTime => _workTimes.fold(
        Duration.zero,
        (acc, time) => acc + (time._endOrNow.difference(time.start)),
      );

  WorkTimeList started(DateTime time) {
    return WorkTimeList([WorkTime(id: '', start: time, end: _timeZero)]);
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
      WorkTime(id: '', start: time, end: _timeZero),
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
  DateTime get _endOrNow => end == _timeZero ? DateTime.now() : end;

  const WorkTime({required this.id, required this.start, required this.end});

  factory WorkTime.fromFirestoreDoc(QueryDocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || doc.metadata.hasPendingWrites) {
      return WorkTime(id: '', start: _timeZero, end: _timeZero);
    }

    return WorkTime(
      id: doc.id,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return <String, dynamic>{
      'start': start,
      'end': end,
    };
  }

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
