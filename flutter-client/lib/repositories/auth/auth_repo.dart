abstract class AuthRepo {
  Stream<String> get userId;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
