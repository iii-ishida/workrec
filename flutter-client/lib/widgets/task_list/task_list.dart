import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:workrec_app/widgets/styles.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import './searchbar.dart';
import './view_model.dart';

class TaskListPage extends StatelessWidget {
  final WorkrecClient client;
  const TaskListPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TaskListViewModel>(
      create: (_) => taskListViewModelStream(client),
      initialData: TaskListViewModel.loading,
      child: Builder(builder: (context) {
        final viewModel = context.watch<TaskListViewModel>();
        return TaskListScreen(viewModel: viewModel);
      }),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  @visibleForTesting
  const TaskListScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  final TaskListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(SpacingUnit.medium),
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
            sliver: TaskList(rows: viewModel.rows),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<TaskListItemViewModel> rows;

  @visibleForTesting
  const TaskList({
    Key? key,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isEven) {
            final row = rows[index ~/ 2];
            return InkWell(
              onTap: () {
                context.push('/tasks/${row.taskId}');
              },
              child: TaskListRow(
                title: row.title,
                description: row.description,
                startTime: row.startTime,
                workingTime: row.workingTime,
                estimatedTime: row.estimatedTime,
                toggleAction: row.toggleAction,
                onToggle: row.onToggle,
              ),
            );
          } else {
            return const Divider(height: 1, color: Color(0xFFE5E5E5));
          }
        },
        childCount: (rows.length * 2) - 1,
      ),
    );
  }
}

class TaskListRow extends StatelessWidget {

  @visibleForTesting
  const TaskListRow({
    Key? key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.workingTime,
    required this.estimatedTime,
    required this.toggleAction,
    required this.onToggle,
  }) : super(key: key);

  final String title;
  final String description;
  final String startTime;
  final String workingTime;
  final String estimatedTime;
  final ToggleAction toggleAction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingUnit.medium),
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
              const SizedBox(height: SpacingUnit.small),
              Text(
                description,
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(height: SpacingUnit.small),
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
              Text(
                '見積もり時間: $estimatedTime分',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          const Spacer(),
          _ToggleButton(toggleAction, onTap: onToggle),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final ToggleAction toggleAction;
  final VoidCallback onTap;

  const _ToggleButton(
    this.toggleAction, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(width: 1, color: Colors.blue),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingUnit.medium,
          vertical: SpacingUnit.small,
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            toggleAction == ToggleAction.suspend
                ? CupertinoIcons.pause
                : CupertinoIcons.play,
            size: SpacingUnit.medium,
          ),
          Text(_toggleButtonLabel(toggleAction)),
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
