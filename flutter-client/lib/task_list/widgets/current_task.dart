import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workrec/workrec.dart';
import 'package:workrec_app/components/hover_card.dart';

class CurrentTask extends StatelessWidget {
  const CurrentTask(this._viewModel, {Key? key, required this.onTap})
      : super(key: key);

  final CurrentTaskViewModel _viewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = HoverCardController();

    return HoverCard(
      onTap: onTap,
      controller: controller,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33007AFF),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viewModel.title,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.stopwatch, size: 30),
                        Text(
                          ' ${_viewModel.currentWorkingTime}',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '開始日時: ${_viewModel.startTime}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '作業時間: ${_viewModel.totalWorkingTime}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HoverCardAnimationDisable(
                    controller: controller,
                    child: _PopupMenuButton(),
                  ),
                  const Spacer(),
                  HoverCardAnimationDisable(
                    controller: controller,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1, color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        children: const [
                          Icon(CupertinoIcons.pause, size: 16),
                          Text('停止')
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum _TaskOption { complete, delete }

class _PopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TaskOption>(
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF2F2F7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<_TaskOption>(
          value: _TaskOption.complete,
          child: Text('完了'),
        ),
        const PopupMenuItem<_TaskOption>(
          value: _TaskOption.delete,
          child: Text('削除'),
        ),
      ],
      onSelected: (result) {},
    );
  }
}

class CurrentTaskViewModel {
  CurrentTaskViewModel(this._task);

  final Task _task;

  final _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  bool get isEmpty => _task.id.isEmpty;
  String get title => _task.title;
  String get startTime =>
      _task.isStarted ? _dateFormat.format(_task.startTime) : '-';
  String get currentWorkingTime =>
      _task.isWorking ? _formatHHMM(_task.currentWorkingTime) : '--:--';
  String get totalWorkingTime {
    final workingTime = (_task.workingTime + _task.currentWorkingTime);
    return _formatHHMM(workingTime);
  }

  String _formatHHMM(Duration duration) {
    final durationInMinutes = duration.inMinutes;
    final hour = '${(durationInMinutes / 60).floor()}'.padLeft(2, '0');
    final minutes = '${durationInMinutes % 60}'.padLeft(2, '0');
    return '$hour:$minutes';
  }
}
