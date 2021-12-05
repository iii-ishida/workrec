import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import 'package:workrec_app/auth_client/auth_client.dart';

import './widgets/auth/auth_page.dart';
import './widgets/auth/auth_provider.dart';
import './widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authClient = AuthClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workrec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthProvider(
        authClient: authClient,
        builder: ((userId) => userId.isEmpty
            ? AuthPage(viewModel: AuthViewModel(authClient: authClient))
            : Home(client: WorkrecClient(userId: userId))),
      ),
    );
  }
}
