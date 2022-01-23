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

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
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

  late final signOut = _auth.signOut;
}
