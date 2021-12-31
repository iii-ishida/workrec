import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './view_model.dart';
import './searchbar.dart';

class TaskList extends StatelessWidget {
  final WorkrecClient client;

  const TaskList({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<TaskListViewModelNotifier, TaskListViewModel>(
      create: (_) => TaskListViewModelNotifier(client),
      child: Builder(builder: (context) {
        final viewModel = context.watch<TaskListViewModel>();

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
                  viewModel: viewModel,
                ),
              ),
            ],
          ),
        );
      }),
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
              description: row.description,
              startTime: row.startTime,
              workingTime: row.workingTime,
              toggleAction: row.toggleAction,
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
    required this.description,
    required this.startTime,
    required this.workingTime,
    required this.toggleAction,
    required this.onToggle,
  }) : super(key: key);

  final String title;
  final String description;
  final String startTime;
  final String workingTime;
  final ToggleAction toggleAction;
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
              Text(
                description,
                style: Theme.of(context).textTheme.caption,
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
                  toggleAction == ToggleAction.suspend
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play,
                  size: 16,
                ),
                Text(_toggleButtonLabel(toggleAction)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _toggleButtonLabel(ToggleAction action) {
    switch (action) {
      case ToggleAction.start:
        return '開始';
      case ToggleAction.suspend:
        return '停止';
      case ToggleAction.resume:
        return '再開';
    }
  }
}
