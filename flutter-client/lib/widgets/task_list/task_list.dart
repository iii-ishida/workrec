import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './view_model.dart';
import './searchbar.dart';

class TaskList extends StatelessWidget {
  final WorkrecClient client;

  const TaskList({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<TaskListPageViewModel>(
        create: (_) => TaskListPageViewModel(client)..listen(),
        child: Builder(builder: (context) {
          final viewModel = context.watch<TaskListPageViewModel>();

          return Container(
            color: Colors.white,
            child: CustomScrollView(
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
                  child: Divider(height: 1, color: Color(0xFFA5A5A5)),
                ),
                SliverSafeArea(
                  top: false,
                  sliver: _TaskListView(
                    viewModel: viewModel.taskListViewModel,
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
            final row = viewModel.rows[index ~/ 2];
            return _TaskListRow(
              title: row.title,
              startTime: row.startTime,
              workingTime: row.workingTime,
              isNextSuspend: row.isNextSuspend,
              toggleButtonLabel: row.toggleButtonLabel,
              onToggle: row.onToggle,
            );
          } else {
            return const Divider(height: 1, color: Color(0xFFE5E5E5));
          }
        },
        childCount: (viewModel.rows.length * 2) - 1,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  const _TaskListRow({
    Key? key,
    required this.title,
    required this.startTime,
    required this.workingTime,
    required this.isNextSuspend,
    required this.toggleButtonLabel,
    required this.onToggle,
  }) : super(key: key);

  final String title;
  final String startTime;
  final String workingTime;
  final bool isNextSuspend;
  final String toggleButtonLabel;
  final VoidCallback onToggle;

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
                title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _space,
              Row(children: [
                Text(
                  '開始日時: $startTime',
                  style: Theme.of(context).textTheme.caption,
                ),
              ]),
              Row(children: [
                Text(
                  '作業時間: $workingTime',
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
            onPressed: onToggle,
            child: Row(
              children: [
                Icon(
                  isNextSuspend ? CupertinoIcons.pause :  CupertinoIcons.play,
                  size: 16,
                ),
                Text(toggleButtonLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}