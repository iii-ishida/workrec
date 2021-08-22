import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec/workrec/repositories/auth/firebase_auth_repo.dart';

import './ui/auth/auth_page.dart';
import './ui/auth/auth_provider.dart';
import './ui/task_list/task_list_page.dart';
import 'workrec/repositories/task/firestore_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authRepo = FirebaseAuthRepo();

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
            : TaskListPage(repo: FirestoreTaskRepo(userId: userId))),
      ),
    );
  }
}
