import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

class Auth {
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

  Stream<String> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid ?? '');
}
