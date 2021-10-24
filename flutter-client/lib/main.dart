import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec/workrec.dart';

import './auth/auth_page.dart';
import './auth/auth_provider.dart';
import './task_list/task_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authRepo = AuthRepo();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthProvider(
        repo: authRepo,
        builder: ((userId) => userId.isEmpty
            ? AuthPage(viewModel: AuthViewModel(repo: authRepo))
            : TaskListPage(client: WorkrecClient(userId: userId))),
      ),
    );
  }
}
