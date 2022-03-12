import 'package:flutter/material.dart';

import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import 'package:workrec_app/workrec_client/workrec_client.dart';
import './view_model.dart';

class WorkTimeList extends StatelessWidget {
  final String taskId;
  const WorkTimeList({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.read<WorkrecClient>();
    return _WorkTimeList(client: client, taskId: taskId);
  }
}

class _WorkTimeList extends StatelessWidget {
  final WorkrecClient client;
  final String taskId;

  const _WorkTimeList({
    Key? key,
    required this.client,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider<WorkTimeListViewModel>(
      initialData: WorkTimeListViewModel.loading,
      create: (_) => workTimeListFuture(
        client,
        taskId,
      ),
      child: Builder(builder: (context) {
        final model = context.watch<WorkTimeListViewModel>();

        return Scaffold(
          appBar: AppBar(title: const Text('WorkTime List')),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: model.rows
                      .map((row) => _WorkTimeListItem(viewModelNotifier: row))
                      .toList(),
                ),
        );
      }),
    );
  }
}

class _WorkTimeListItem extends StatelessWidget {
  final WorkTimeListItemViewModelNotifier viewModelNotifier;
  const _WorkTimeListItem({Key? key, required this.viewModelNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<WorkTimeListItemViewModelNotifier,
        WorkTimeListItemViewModel>.value(
      value: viewModelNotifier,
      child: Builder(builder: (context) {
        final model = context.watch<WorkTimeListItemViewModel>();

        return Row(children: [
          _DateTimeInput(
            text: model.start.text,
            initialDateTime: model.start.initialDateTime,
            firstDateTime: model.start.firstDateTime,
            lastDateTime: model.start.lastDateTime,
            onChanged: model.onChangeStart,
          ),
          const Text('~'),
          model.hasEnd
              ? _DateTimeInput(
                  text: model.end.text,
                  initialDateTime: model.end.initialDateTime,
                  firstDateTime: model.end.firstDateTime,
                  lastDateTime: model.end.lastDateTime,
                  onChanged: model.onChangeEnd,
                )
              : const Text('-'),
          if (model.hasChanged)
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: model.onSave,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ]);
      }),
    );
  }
}

class _DateTimeInput extends StatelessWidget {
  final String text;
  final DateTime initialDateTime;
  final DateTime firstDateTime;
  final DateTime lastDateTime;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeInput({
    Key? key,
    required this.text,
    required this.initialDateTime,
    required this.firstDateTime,
    required this.lastDateTime,
    required this.onChanged,
  }) : super(key: key);

  DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
  TimeOfDay _time(DateTime d) => TimeOfDay(hour: d.hour, minute: d.minute);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final dateTime = await _inputDateTime(
          context,
          initialDateTime,
          firstDateTime,
          lastDateTime,
        );
        if (dateTime == null || dateTime.isAtSameMomentAs(initialDateTime)) {
          return;
        }

        onChanged(dateTime);
      },
      child: Text(text),
    );
  }

  Future<DateTime?> _inputDateTime(
    BuildContext context,
    DateTime initialDateTime,
    DateTime firstDateTime,
    DateTime lastDateTime,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date(initialDateTime),
      firstDate: firstDateTime,
      lastDate: lastDateTime,
    );
    if (date == null) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: _time(initialDateTime),
    );
    if (time == null) {
      return null;
    }

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}