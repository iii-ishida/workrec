import 'package:flutter/material.dart';
import 'package:workrec/workrec/auth/auth.dart';
import 'package:workrec/workrec/auth/provider.dart';

import './widgets/auth_page.dart';
import './widgets/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthProvider(
        auth: Auth(),
        builder: (_, auth, userId) => userId == ''
            ? AuthPage(signIn: auth.signInWithEmailAndPassword)
            : Home(
                userId: userId,
                signOut: auth.signOut,
              ),
      ),
    );
  }
}
