import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/widgets/styles.dart';

class AddNewTask extends StatelessWidget {
  const AddNewTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _AddNewTask(client: WorkrecClient(userId: userId));
  }
}

class _AddNewTask extends StatelessWidget {
  final WorkrecClient client;
  final ViewModel _model;
  final _formKey = GlobalKey<FormState>();

  _AddNewTask({Key? key, required this.client})
      : _model = ViewModel(client: client),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              await _model.addTask();
              Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingUnit.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: SpacingUnit.medium),
              TextFormField(
                decoration: const InputDecoration(labelText: 'タイトル'),
                onChanged: _model.onChangeTitle,
                validator: (_) =>
                    _model.validateTitle() ? null : 'タイトルを入力してください',
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _model.onChangeEstimatedTime,
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: '説明'),
                  maxLines: null,
                  onChanged: _model.onChangeDescription,
                ),
              ),
              SafeArea(top: false, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewModel {
  final WorkrecClient client;

  @visibleForTesting
  ViewModel({required this.client});

  String _title = '';
  String _description = '';
  String _estimatedTime = '';

  Future<void> addTask() async {
    if (!validateTitle()) {
      return;
    }

    await client.addNewTask(
      title: _title,
      description: _description,
      estimatedTime: int.tryParse(_estimatedTime) ?? 0,
    );
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
