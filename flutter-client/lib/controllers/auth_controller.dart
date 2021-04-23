import 'dart:async';
import 'package:state_notifier/state_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

class AuthController extends StateNotifier<String> {
  AuthController() : super('');

  StreamSubscription<String> listenAuth() {
    return _auth
        .authStateChanges()
        .map((user) => user?.uid ?? '')
        .listen((userId) => state = userId);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
