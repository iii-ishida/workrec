import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

import './view_model.dart';

class WorkTimeList extends StatelessWidget {
  final String taskId;
  const WorkTimeList({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _WorkTimeList(client: WorkrecClient(userId: userId), taskId: taskId);
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
    return StateNotifierProvider<WorkTimeListViewModelNotifier,
        WorkTimeListViewModel>(
      create: (_) => WorkTimeListViewModelNotifier(
        client: client,
        taskId: taskId,
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
        return _WorkTimeListItemBody(viewModel: model);
      }),
    );
  }
}

class _WorkTimeListItemBody extends StatelessWidget {
  final WorkTimeListItemViewModel viewModel;

  const _WorkTimeListItemBody({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _DateTimeInput(
        text: viewModel.start.text,
        initialDateTime: viewModel.start.value,
        firstDateTime: viewModel.start.min,
        lastDateTime: viewModel.start.max,
        onChanged: viewModel.onChangeStart,
      ),
      const Text('~'),
      viewModel.hasEnd
          ? _DateTimeInput(
              text: viewModel.end.text,
              initialDateTime: viewModel.end.value,
              firstDateTime: viewModel.end.min,
              lastDateTime: viewModel.end.max,
              onChanged: viewModel.onChangeEnd,
            )
          : const Text('-'),
      if (viewModel.hasChanged)
        TextButton(
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: viewModel.onSave,
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.black),
          ),
        ),
    ]);
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
