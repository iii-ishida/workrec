import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workrec/domain/task_recorder/task.dart';
import 'package:workrec/domain/task_recorder/task_recorder.dart';
import 'package:workrec/repository/task_recorder/task_repo.dart';

import './widgets/current_task.dart';
import './widgets/searchbar.dart';
import './widgets/add_task_field.dart';

typedef _RecordTaskFunc = Future<void> Function(TaskRecorder, String);

class TaskListPage extends StatelessWidget {
  final TaskListRepo repo;

  const TaskListPage({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamProvider<TaskRecorder>(
        create: (_) => repo.taskRecorder(),
        initialData: TaskRecorder(tasks: const [], currentTaskId: ''),
        child: Builder(builder: (context) {
          final recorder = context.watch<TaskRecorder>();

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
                          child: SearchBar(onChangeSearchText: (_) {}),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CurrentTask(
                          CurrentTaskViewModel(recorder.currentTask),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: _TaskListView(
                        recorder: recorder,
                        startTask: repo.recordStartTimeOfTask,
                        suspendTask: repo.recordSuspendTimeOfTask,
                        resumeTask: repo.recordResumeTimeOfTask,
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
                    child: AddTaskField(onChangeTitle: (_) {}),
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
  final TaskRecorder recorder;
  final _RecordTaskFunc startTask;
  final _RecordTaskFunc suspendTask;
  final _RecordTaskFunc resumeTask;

  const _TaskListView({
    Key? key,
    required this.recorder,
    required this.startTask,
    required this.suspendTask,
    required this.resumeTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recorder = context.watch<TaskRecorder>();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isEven) {
            final isFirst = index == 0;
            final isLast = index ~/ 2 == recorder.tasks.length - 1;
            return _TaskListRow(
              isFirst: isFirst,
              isLast: isLast,
              recorder: recorder,
              task: recorder.tasks[index ~/ 2],
              startTask: startTask,
              suspendTask: suspendTask,
              resumeTask: resumeTask,
            );
          } else {
            return const Divider(height: 1, color: Color(0xFFE5E5E5));
          }
        },
        childCount: (recorder.tasks.length * 2) - 1,
      ),
    );
  }
}

class _TaskListRow extends StatelessWidget {
  _TaskListRow({
    Key? key,
    this.isFirst = false,
    this.isLast = false,
    required TaskRecorder recorder,
    required Task task,
    required _RecordTaskFunc startTask,
    required _RecordTaskFunc suspendTask,
    required _RecordTaskFunc resumeTask,
  })  : model = ViewModel(
          recorder: recorder,
          task: task,
          start: startTask,
          suspend: suspendTask,
          resume: resumeTask,
        ),
        super(key: key);

  final ViewModel model;
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
                model.title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _space,
              Row(children: [
                Text(
                  '開始日時: ${model.startTime}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ]),
              Row(children: [
                Text(
                  '作業時間: ${model.workingTime}',
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
            onPressed: () => model.handleToggle(),
            child: Row(
              children: [
                Icon(
                  model.isActionStart
                      ? CupertinoIcons.play
                      : CupertinoIcons.pause,
                  size: 16,
                ),
                Text(model.actionName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewModel {
  @visibleForTesting
  ViewModel({
    required this.recorder,
    required this.task,
    required this.start,
    required this.suspend,
    required this.resume,
  });

  final TaskRecorder recorder;
  final Task task;
  final _RecordTaskFunc start;
  final _RecordTaskFunc suspend;
  final _RecordTaskFunc resume;

  final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  String get title => task.title;
  String get startTime =>
      task.isStarted ? _dateFormat.format(task.startTime) : '-';

  String get workingTime {
    final workingMinutes = task.workingTime.inMinutes;
    final hour = '${(workingMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${workingMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }

  Color get stateColor {
    if (!task.isStarted) {
      return Colors.grey;
    }
    if (task.isWorking) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  String get actionName {
    if (!task.isStarted) {
      return '開始';
    } else if (task.isWorking) {
      return '停止';
    } else {
      return '再開';
    }
  }

  bool get isActionStart => !task.isWorking;

  Future<void> handleToggle() async {
    if (!task.isStarted) {
      return await _handleStart();
    }
    if (task.isWorking) {
      return await _handleSuspend();
    } else {
      return await _handleResume();
    }
  }

  Future<void> _handleStart() async {
    await start(recorder, task.id);
  }

  Future<void> _handleSuspend() async {
    await suspend(recorder, task.id);
  }

  Future<void> _handleResume() async {
    await resume(recorder, task.id);
  }
}
