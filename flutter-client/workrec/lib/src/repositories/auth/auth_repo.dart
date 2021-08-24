import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final FirebaseAuth _auth;

  AuthRepo({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<String> get userId =>
      _auth.authStateChanges().map((user) => user?.uid ?? '');

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> signOut() => _auth.signOut();
}
