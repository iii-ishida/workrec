import 'package:flutter/material.dart';
import 'package:workrec/widgets/add_task_page.dart';
import 'package:workrec/widgets/task_list_page.dart';
import 'package:workrec/workrec/task/provider.dart';
import 'package:workrec/workrec/task/repo.dart';

typedef _SignOutFunc = Future<void> Function();

class Home extends StatelessWidget {
  Home({
    Key? key,
    required this.userId,
    required this.signOut,
  }) : super(key: key);

  final String userId;
  final _SignOutFunc signOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workrec'),
      ),
      drawer: _Drawer(signOut: signOut),
      body: TaskListProvider(
        userId: userId,
        builder: (context, taskList) => TaskListPage(
          taskList: taskList,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<AddTaskPage>(
                builder: (_) => AddTaskPage(addTask: TaskListRepo().addTask)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({Key? key, required this.signOut}) : super(key: key);

  final _SignOutFunc signOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: DrawerHeader(
              child:
                  const Text('Workrec', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ListTile(
            title: const Text('ログアウト'),
            onTap: () {
              signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
