import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String id;
  const AuthUser({this.id = ''});
}

class AuthClient {
  final FirebaseAuth _auth;

  AuthClient({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  AuthUser get currentUser => AuthUser(id: _auth.currentUser?.uid ?? '');

  Stream<AuthUser> get userStream =>
      _auth.authStateChanges().map((user) => AuthUser(id: user?.uid ?? ''));

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
