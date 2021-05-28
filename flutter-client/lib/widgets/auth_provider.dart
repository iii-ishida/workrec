import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends StatelessWidget {
  final Widget Function(String userId) builder;
  final FirebaseAuth auth;

  const AuthProvider({
    Key? key,
    required this.auth,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>(
      create: (_) => auth.authStateChanges().map((user) => user?.uid ?? ''),
      initialData: '',
      child: Builder(builder: (context) {
        final userId = context.watch<String>();
        return builder(userId);
      }),
    );
  }
}
