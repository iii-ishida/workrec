import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddTaskField extends StatefulWidget {
  const AddTaskField({Key? key, required this.onAddTask}) : super(key: key);

  final ValueChanged<String> onAddTask;

  @override
  State<StatefulWidget> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: SizedBox(
          height: 44,
          child: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(
                  CupertinoIcons.plus,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 20 + 12,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              filled: true,
              fillColor: Color(0xB3D4D4D4),
              labelText: 'タスク追加',
              labelStyle: TextStyle(color: Colors.blue),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 15),
            onSubmitted: (title) {
              if (title.isNotEmpty) {
                widget.onAddTask(title);
              }
              _titleController.clear();
            },
          ),
        ),
      ),
    );
  }
}
