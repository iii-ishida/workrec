import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:workrec/repository/task_recorder/task_repo.dart';

import 'package:workrec/pages/task_detail_page.dart';

import './view_model.dart';
import './widgets/current_task.dart';
import './widgets/searchbar.dart';
import './widgets/add_task_field.dart';

class TaskListPage extends StatelessWidget {
  final TaskListRepo repo;

  const TaskListPage({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<TaskListPageViewModel>(
        create: (_) => TaskListPageViewModel(repo)..listen(),
        child: Builder(builder: (context) {
          final viewModel = context.watch<TaskListPageViewModel>();

          return Container(
            color: const Color(0xFFF3F3F3),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomScrollView(
                  slivers: [
                    SliverSafeArea(
                      bottom: false,
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SearchBar(
                            onChangeSearchText: viewModel.onChangeSearchText,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CurrentTask(viewModel.currentTaskViewModel,
                            onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (context) => TaskDetailPage(
                                    repo: repo,
                                    taskId: viewModel.currentTaskId)),
                          );
                        }),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: _TaskListView(
                        viewModel: viewModel.taskListViewModel,
                      ),
                    ),
                    const SliverSafeArea(
                      top: false,
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(height: 44),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AddTaskField(onAddTask: viewModel.onAddTask),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final TaskListViewModel viewModel;

  const _TaskListView({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isEven) {
            final isFirst = index == 0;
            final isLast =
                index ~/ 2 == viewModel.taskListItemViewModels.length - 1;
            return _TaskListRow(
              isFirst: isFirst,
              isLast: isLast,
              viewModel: viewModel.taskListItemViewModels[index ~/ 2],
            );
          } else {
            return const Divider(height: 1, color: Color(0xFFE5E5E5));
          }
        },
        childCount: (viewModel.taskListItemViewModels.length * 2) - 1,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  const _TaskListRow({
    Key? key,
    required this.viewModel,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  final TaskListItemViewModel viewModel;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const _space = SizedBox(height: 8, width: 8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : (isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : BorderRadius.zero),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _space,
              Row(children: [
                Text(
                  '開始日時: ${viewModel.startTime}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ]),
              Row(children: [
                Text(
                  '作業時間: ${viewModel.workingTime}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ]),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1, color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => viewModel.handleToggle(),
            child: Row(
              children: [
                Icon(
                  viewModel.isActionStart
                      ? CupertinoIcons.play
                      : CupertinoIcons.pause,
                  size: 16,
                ),
                Text(viewModel.actionName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
