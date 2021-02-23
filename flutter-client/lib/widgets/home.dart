import 'package:flutter/material.dart';
import 'package:workrec/workrec/auth/auth.dart';
import 'package:workrec/workrec/auth/provider.dart';

import './auth_page.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthProvider(
        builder: (_context, userId) => userId == ''
            ? AuthPage(signIn: Auth().signIn)
            : Center(
                child: ElevatedButton(
                  onPressed: () => Auth().signOut(),
                  child: Text('ログアウト'),
                ),
              ),
      ),
    );
  }
}
