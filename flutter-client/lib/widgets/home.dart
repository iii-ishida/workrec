import 'package:flutter/material.dart';
import 'package:workrec/widgets/add_task_page.dart';
import 'package:workrec/widgets/task_list_page.dart';
import 'package:workrec/repositories/task_recorder/task_repo.dart';
import 'package:workrec/repositories/task_recorder/firestore_repo.dart';

typedef _SignOutFunc = Future<void> Function();

class Home extends StatelessWidget {
  Home({
    Key? key,
    required this.userId,
    required this.signOut,
  })  : taskRepo = FirestoreTaskRepo(userId: userId),
        super(key: key);

  final String userId;
  final _SignOutFunc signOut;
  final TaskListRepo taskRepo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workrec'),
      ),
      drawer: _Drawer(signOut: signOut),
      body: TaskListPage(repo: taskRepo),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<AddTaskPage>(
              builder: (_) => AddTaskPage(addTask: taskRepo.addNewTask),
            ),
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
          SizedBox(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Workrec',
                style: TextStyle(color: Colors.white),
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
