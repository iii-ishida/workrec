import 'package:flutter/material.dart';
import 'package:workrec/workrec/models/task_recorder.dart';

typedef _AddTaskFunc = Future<void> Function(TaskRecorder, String);

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key, required this.addTask}) : super(key: key);

  final _AddTaskFunc addTask;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late final ViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = ViewModel(addTask: widget.addTask);
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
      ),
      body: Form(
          key: _model.formKey,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: TextFormField(
                controller: _model.titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
                validator: (_) =>
                    _model.validateTitle() ? null : 'タイトルを入力してください',
                onEditingComplete: () async {
                  if (await _model.handleAddTask()) {
                    Navigator.pop(context);
                  }
                }),
          )),
    );
  }
}

class ViewModel {
  @visibleForTesting
  ViewModel({required this.addTask});

  final _AddTaskFunc addTask;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  Future<bool> handleAddTask() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }
    await addTask(
      TaskRecorder(tasks: const [], currentTaskId: ''),
      titleController.text,
    );
    return true;
  }

  bool validateTitle() => titleController.text.isNotEmpty;

  void dispose() {
    titleController.dispose();
  }
}
