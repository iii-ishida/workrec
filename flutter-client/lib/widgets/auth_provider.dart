import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:workrec/controllers/auth_controller.dart';

typedef SignInFunc = Future<void> Function({
  required String email,
  required String password,
});
typedef SignOutFunc = Future<void> Function();

class AuthProvider extends StatefulWidget {
  final Widget child;
  final AuthController controller;

  AuthProvider({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AuthProvider> {
  late final StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.controller.listenAuth();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<AuthController, String>.value(
      value: widget.controller,
      builder: (context, _) => widget.child,
    );
  }
}
