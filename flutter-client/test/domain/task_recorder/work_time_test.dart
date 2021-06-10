import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/domain/task_recorder/work_time.dart';

void main() {
  group('WorkTime.workingTime', () {
    test('start から end の経過時間を返すこと', () {
      final actual = WorkTime(
        id: '',
        start: DateTime(2021, 1, 1, 10, 0),
        end: DateTime(2021, 1, 1, 12, 0),
      ).workingTime;

      expect(actual, const Duration(hours: 2));
    });
    test('end が未設定の場合は StateError を throw すること', () {
      final workTime = WorkTime(id: '', start: DateTime(2021, 1, 1, 10, 0));
      expect(() => workTime.workingTime, throwsA(isStateError));
    });
  });
}
