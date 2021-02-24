import 'package:flutter/material.dart';
import 'package:workrec/widgets/task_list_page.dart';
import 'package:workrec/workrec/auth/auth.dart';
import 'package:workrec/workrec/task/provider.dart';

class Home extends StatelessWidget {
  Home({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workrec'),
      ),
      drawer: _Drawer(),
      body: TaskListProvider(
        userId: userId,
        builder: (context, taskList) => TaskListPage(
          taskList: taskList,
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
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
              Auth().signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
