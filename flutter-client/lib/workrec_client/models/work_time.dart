import 'package:equatable/equatable.dart';

final _dateTimeZero = DateTime.fromMillisecondsSinceEpoch(0);

/// 作業時間
class WorkTime extends Equatable {
  /// id
  final String id;

  /// 開始日時
  final DateTime start;

  /// 終了日時
  final DateTime end;

  WorkTime({required this.id, required this.start, DateTime? end})
      : end = end ?? _dateTimeZero;

  static final empty = WorkTime(id: '', start: _dateTimeZero);

  /// 作業した時間を返します
  /// [end] が未設定の場合は [StateError] を throw します
  Duration get workingTime =>
      hasEnd ? end.difference(start) : throw StateError('no end');

  /// [end] が設定されている場合は true
  bool get hasEnd => end != _dateTimeZero;

  /// [start] [end] を更新します
  WorkTime patch({DateTime? start, DateTime? end}) {
    return _copyWith(start: start, end: end);
  }

  WorkTime _copyWith({DateTime? start, DateTime? end}) {
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
