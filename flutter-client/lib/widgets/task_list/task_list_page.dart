import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec.dart';

import './view_model.dart';
import './widgets/add_task_field.dart';
import './widgets/searchbar.dart';

class TaskListPage extends StatelessWidget {
  final WorkrecClient client;

  const TaskListPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<TaskListPageViewModel>(
        create: (_) => TaskListPageViewModel(client)..listen(),
        child: Builder(builder: (context) {
          final viewModel = context.watch<TaskListPageViewModel>();

          return Container(
            color: Colors.white,
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
                    const SliverToBoxAdapter(
                      child: Divider(
                        height: 1,
                        color: Color(0xFFA5A5A5),
                      ),
                    ),
                    SliverSafeArea(
                      top: false,
                      sliver: _TaskListView(
                        viewModel: viewModel.taskListViewModel,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 44)),
                  ],
                ),
                SafeArea(
                  top: false,
                  child: AddTaskField(onAddTask: viewModel.onAddTask),
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
            return _TaskListRow(
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
  }) : super(key: key);

  final TaskListItemViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    const _space = SizedBox(height: 8, width: 8);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 14,
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
