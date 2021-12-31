import 'package:flutter_test/flutter_test.dart';
import 'package:workrec_app/widgets/task_list/view_model.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

void main() {
  group('TaskListViewModel', () {
    late TaskListViewModel model;

    setUp(() {
      model = TaskListViewModel(
          tasks: [
            Task.create(title: 'some task', description: 'some description')
                .start(DateTime(2021, 1, 2, 10, 0))
                .suspend(DateTime(2021, 1, 2, 12, 30)),
          ],
          startTask: (_) async {},
          suspendTask: (_) async {},
          resumeTask: (_) async {});
    });

    group('.rows', () {
      test('title', () {
        expect(model.rows[0].title, 'some task');
      });
      test('description', () {
        expect(model.rows[0].description, 'some description');
      });
      test('startTime', () {
        expect(model.rows[0].startTime, '2021-01-02 10:00');
      });
      test('workingTime', () {
        expect(model.rows[0].workingTime, '02:30');
      });
      test('toggleAction', () {
        expect(model.rows[0].toggleAction, ToggleAction.resume);
      });
    });
  });
}
