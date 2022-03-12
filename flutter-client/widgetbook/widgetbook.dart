import 'dart:math';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:workrec_app/widgets/task_list/task_list.dart';
import 'package:workrec_app/widgets/task_list/view_model.dart';
import 'package:workrec_app/workrec_client/models/models.dart';

// ignore_for_file: invalid_use_of_visible_for_testing_member
class HotreloadWidgetbook extends StatelessWidget {
  const HotreloadWidgetbook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appInfo: AppInfo(name: 'Workrec App'),
      defaultTheme: ThemeMode.light,
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      categories: [
        WidgetbookCategory(
          name: 'pages',
          folders: [
            WidgetbookFolder(
              name: 'TaskListPage',
              widgets: [
                WidgetbookWidget(
                  name: 'TaskList',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Loading',
                      builder: (context) => CustomScrollView(slivers: [
                        TaskList(
                          viewModel: TaskListViewModel.loading,
                        )
                      ]),
                    ),
                    WidgetbookUseCase(
                      name: 'Dafault',
                      builder: (context) => CustomScrollView(slivers: [
                        TaskList(
                          viewModel: _newViewModel(
                            [
                              _newRow(
                                title: '開始タスク',
                                description: 'xxxx',
                                startTime: '2022-02-01 10:00',
                                estimatedTime: 30,
                                toggleAction: ToggleAction.suspend,
                              ),
                              _newRow(
                                title: '停止中タスク',
                                description: 'yyyy',
                                startTime: '2022-02-01 10:00',
                                workingTime: '00:30',
                                toggleAction: ToggleAction.resume,
                              ),
                              _newRow(
                                title: '作業中タスク',
                                description: 'zzzz',
                                startTime: '2022-02-01 10:00',
                                workingTime: '01:30',
                                toggleAction: ToggleAction.suspend,
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FixtureTaskListViewModel implements TaskListViewModel {
  _FixtureTaskListViewModel(this._rows);
  final List<TaskListItemViewModel> _rows;

  @override
  bool get isLoading => false;

  @override
  List<Task> get tasks => [];

  @override
  Future<void> Function(String) get startTask => (_) async {};

  @override
  Future<void> Function(String) get suspendTask => (_) async {};

  @override
  Future<void> Function(String) get resumeTask => (_) async {};

  @override
  void onChangeSearchText(String _) {}

  @override
  List<TaskListItemViewModel> get rows => _rows;
}

class _FixtureTaskListItemViewModel implements TaskListItemViewModel {
  _FixtureTaskListItemViewModel({
    required this.taskId,
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.startTime,
    required this.workingTime,
    required this.toggleAction,
  });

  @override
  final String taskId;

  @override
  final String title;

  @override
  final String description;

  @override
  final String estimatedTime;

  @override
  final String startTime;

  @override
  final String workingTime;

  @override
  final ToggleAction toggleAction;

  @override
  Future<void> Function() get onToggle => () async {};
}

TaskListViewModel _newViewModel(List<TaskListItemViewModel> rows) =>
    _FixtureTaskListViewModel(rows);

final _random = Random();
TaskListItemViewModel _newRow({
  String? id,
  String? title,
  String? description,
  int? estimatedTime,
  String? startTime,
  String? workingTime,
  ToggleAction? toggleAction,
}) =>
    _FixtureTaskListItemViewModel(
      taskId: id ?? _random.nextInt(10000).toString(),
      title: title ?? '新規作業',
      description: description ?? '',
      estimatedTime: estimatedTime?.toString() ?? '0',
      startTime: startTime ?? '',
      workingTime: workingTime ?? '00:00',
      toggleAction: toggleAction ?? ToggleAction.start,
    );
