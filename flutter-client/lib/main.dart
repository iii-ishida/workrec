import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthProvider(
        auth: auth,
        builder: ((userId) => userId.isEmpty
            ? AuthPage(signIn: auth.signInWithEmailAndPassword)
            : Home(userId: userId, signOut: auth.signOut)),
      ),
    );
  }
}
