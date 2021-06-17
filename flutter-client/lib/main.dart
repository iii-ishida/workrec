import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec/repositories/auth/firebase_auth_repo.dart';
import './widgets/auth_page.dart';
import './widgets/auth_provider.dart';
import './widgets/home.dart';

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
      home: AuthProvider(
        repo: authRepo,
        builder: ((userId) => userId.isEmpty
            ? AuthPage(viewModel: AuthViewModel(repo: authRepo))
            : Home(userId: userId, signOut: authRepo.signOut)),
      ),
    );
  }
}
