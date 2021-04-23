import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/controllers/auth_controller.dart';
import './widgets/auth_page.dart';
import './widgets/auth_provider.dart';
import './widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthProvider(
        controller: authController,
        child: Builder(builder: (context) {
          final userId = context.watch<String>();
          return userId.isEmpty
              ? AuthPage(signIn: authController.signInWithEmailAndPassword)
              : Home(
                  userId: userId,
                  signOut: authController.signOut,
                );
        }),
      ),
    );
  }
}
