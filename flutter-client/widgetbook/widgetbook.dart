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
                          viewModel: TaskListViewModel(
                            isLoading: false,
                            tasks: [
                              _newTask(title: '開始タスク', description: 'タスク説明')
                                  .start(DateTime(2022, 2, 1, 10, 0)),
                              _newTask(title: '停止中タスク', description: 'タスク説明')
                                  .start(DateTime(2022, 2, 1, 10, 0))
                                  .suspend(DateTime(2022, 2, 1, 12, 0)),
                              _newTask(title: '作業中タスク', description: 'タスク説明')
                                  .start(DateTime(2022, 2, 1, 10, 0))
                                  .suspend(DateTime(2022, 2, 1, 12, 0))
                                  .resume(DateTime(2022, 2, 1, 13, 0)),
                            ],
                            startTask: (_) async {},
                            suspendTask: (_) async {},
                            resumeTask: (_) async {},
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

final random = Random();
Task _newTask({
  String? id,
  String? title,
  String? description,
  int? estimatedTime,
}) =>
    Task(
      id: id ?? random.nextInt(10000).toString(),
      state: TaskState.unstarted,
      title: title ?? '新規作業',
      description: description ?? '',
      estimatedTime: estimatedTime ?? 0,
      timeRecords: const [],
    );
