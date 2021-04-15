import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workrec/domain/auth/auth.dart';

class AuthCommand {
  final Future<void> Function({
    required String email,
    required String password,
  }) signInWithEmailAndPassword;
  final Future<void> Function() signOut;

  AuthCommand({
    required this.signInWithEmailAndPassword,
    required this.signOut,
  });
}

class AuthProvider extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    AuthCommand command,
    String userId,
  ) builder;

  final Auth auth;

  final AuthCommand _command;

  AuthProvider({
    Key? key,
    required this.auth,
    required this.builder,
  })   : _command = AuthCommand(
          signInWithEmailAndPassword: auth.signInWithEmailAndPassword,
          signOut: auth.signOut,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>.value(
      initialData: '',
      value: auth.authStateChanges,
      child: Consumer<String>(
        builder: (context, value, _) => builder(context, _command, value),
      ),
    );
  }
}
