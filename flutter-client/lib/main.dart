import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec/domain/auth/auth.dart';

import './widgets/auth_page.dart';
import './widgets/auth_provider.dart';
import './widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        builder: (_, command, userId) => userId == ''
            ? AuthPage(signIn: command.signInWithEmailAndPassword)
            : Home(
                userId: userId,
                signOut: command.signOut,
              ),
      ),
    );
  }
}
