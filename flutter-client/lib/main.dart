import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec/repository/auth/firebase_auth_repo.dart';
import './pages/auth/auth_page.dart';
import './pages/auth/auth_provider.dart';
import './pages/task_list/task_list_page.dart';
import './repository/task_recorder/firestore_repo.dart';

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
