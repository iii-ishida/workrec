import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/workrec_client/models/task.dart';

class EditTask extends StatelessWidget {
  final String taskId;
  const EditTask({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _EditTask(client: WorkrecClient(userId: userId), taskId: taskId);
  }
}

class _EditTask extends StatelessWidget {
  final WorkrecClient client;
  final String taskId;
  final _formKey = GlobalKey<FormState>();

  _EditTask({Key? key, required this.client, required this.taskId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<ViewModelNotifier, ViewModel>(
      create: (_) => ViewModelNotifier(client: client, taskId: taskId),
      child: Builder(builder: (context) {
        final model = context.watch<ViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Task'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  await model.editTask();
                  Navigator.pop(context);
                },
                child: const Text('保存'),
              ),
            ],
          ),
          body: model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'タイトル'),
                          initialValue: model.title,
                          onChanged: model.onChangeTitle,
                          validator: (_) =>
                              model.validateTitle() ? null : 'タイトルを入力してください',
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: '見積もり時間',
                            suffix: Text('分'),
                          ),
                          textAlign: TextAlign.end,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          initialValue: model.estimatedTime,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: model.onChangeEstimatedTime,
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: '説明'),
                            maxLines: null,
                            initialValue: model.description,
                            onChanged: model.onChangeDescription,
                          ),
                        ),
                        SafeArea(top: false, child: Container()),
                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}

class ViewModelNotifier extends StateNotifier<ViewModel> {
  final WorkrecClient client;
  final String taskId;

  ViewModelNotifier({required this.client, required this.taskId})
      : super(ViewModel(
            isLoading: true, task: Task.empty, onEdit: (_, __, ___) async {})) {
    client.findTaskById(taskId).then((task) => state = ViewModel(
        task: task,
        onEdit: (title, description, estimatedTime) async {
          await client.updateTask(task,
              title: title,
              description: description,
              estimatedTime: estimatedTime);
        }));
  }
}

class ViewModel {
  final bool isLoading;
  final Task task;
  final Future<void> Function(
      String title, String description, int estimatedTime) onEdit;

  @visibleForTesting
  ViewModel({required this.task, required this.onEdit, this.isLoading = false})
      : _title = task.title,
        _description = task.description,
        _estimatedTime = '${task.estimatedTime}';

  String _title;
  String get title => _title;

  String _description;
  String get description => _description;

  String _estimatedTime;
  String get estimatedTime => _estimatedTime;

  Future<void> editTask() async {
    await onEdit(_title, _description, int.tryParse(_estimatedTime) ?? 0);
  }

  void onChangeTitle(String title) {
    _title = title;
  }

  void onChangeDescription(String description) {
    _description = description;
  }

  void onChangeEstimatedTime(String estimatedTime) {
    _estimatedTime = estimatedTime;
  }

  bool validateTitle() => _title.isNotEmpty;
}
