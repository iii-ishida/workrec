import 'package:firebase_auth/firebase_auth.dart';
import './auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth _auth;

  FirebaseAuthRepo({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<String> get userId =>
      _auth.authStateChanges().map((user) => user?.uid ?? '');

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> signOut() => _auth.signOut();
}
