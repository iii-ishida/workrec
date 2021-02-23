import 'package:flutter/material.dart';
import 'package:workrec/workrec/auth/auth.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workrec'),
      ),
      drawer: _Drawer(),
      body: const Center(
        child: Text('Hello'),
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
              child: const Text('Workrec', style: TextStyle(color: Colors.white)),
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
