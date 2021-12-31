import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';

class AddNewTask extends StatelessWidget {
  const AddNewTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthUser>().id;
    return _AddNewTask(client: WorkrecClient(userId: userId));
  }
}

class _AddNewTask extends StatefulWidget {
  final WorkrecClient client;

  const _AddNewTask({Key? key, required this.client}) : super(key: key);

  @override
  State<_AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<_AddNewTask> {
  late final ViewModel _model;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = ViewModel(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary),
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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'タイトル'),
                onChanged: _model.onChangeTitle,
                validator: (_) =>
                    _model.validateTitle() ? null : 'タイトルを入力してください',
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

  Future<void> addTask() async {
    if (!validateTitle()) {
      return;
    }

    await client.addNewTask(title: _title, description: _description);
  }

  void onChangeTitle(String title) {
    _title = title;
  }

  void onChangeDescription(String description) {
    _description = description;
  }

  bool validateTitle() => _title.isNotEmpty;
}
