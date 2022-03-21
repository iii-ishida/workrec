import 'dart:math';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:workrec_app/widgets/task_list/task_list.dart';
import 'package:workrec_app/widgets/task_list/view_model.dart';

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
                          viewModel: TaskListViewModel(
                            isLoading: false,
                            rows: [
                              _newRow(
                                title: '開始タスク',
                                description: 'xxxx',
                                startTime: DateTime(2022, 2, 1, 10, 0),
                                estimatedTime: const Duration(minutes: 30),
                                toggleAction: ToggleAction.suspend,
                              ),
                              _newRow(
                                title: '停止中タスク',
                                description: 'yyyy',
                                startTime: DateTime(2022, 2, 1, 10, 0),
                                workingTime: const Duration(minutes: 30),
                                toggleAction: ToggleAction.resume,
                              ),
                              _newRow(
                                title: '作業中タスク',
                                description: 'zzzz',
                                startTime: DateTime(2022, 2, 1, 10, 0),
                                workingTime: const Duration(minutes: 90),
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

final _random = Random();
TaskListItemViewModel _newRow({
  String? taskId,
  String? title,
  String? description,
  Duration? estimatedTime,
  Duration? workingTime,
  DateTime? startTime,
  ToggleAction? toggleAction,
}) =>
    TaskListItemViewModel(
      taskId: taskId ?? _random.nextInt(10000).toString(),
      title: title ?? '新規作業',
      description: description ?? '',
      estimatedTime: estimatedTime ?? Duration.zero,
      startTime: startTime,
      workingTime: workingTime ?? Duration.zero,
      toggleAction: toggleAction ?? ToggleAction.start,
      onToggle: () async {},
    );
