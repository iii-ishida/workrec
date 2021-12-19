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

  @override
  void initState() {
    super.initState();
    _model = ViewModel(client: widget.client);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
              if (await _model.handleAddTask()) {
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
      body: Form(
        key: _model.formKey,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: TextFormField(
            controller: _model.titleController,
            decoration: const InputDecoration(labelText: 'タイトル'),
            validator: (_) => _model.validateTitle() ? null : 'タイトルを入力してください',
          ),
        ),
      ),
    );
  }
}

class ViewModel {
  @visibleForTesting
  ViewModel({required this.client});

  final WorkrecClient client;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  Future<bool> handleAddTask() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    await client.addNewTask(title: titleController.text);
    return true;
  }

  bool validateTitle() => titleController.text.isNotEmpty;

  void dispose() {
    titleController.dispose();
  }
}
