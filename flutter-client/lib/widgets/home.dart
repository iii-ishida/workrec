import 'package:flutter/material.dart';
import 'package:workrec/workrec/auth/auth.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workrec'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Auth().signOut(),
          child: Text('ログアウト'),
        ),
      ),
    );
  }
}
