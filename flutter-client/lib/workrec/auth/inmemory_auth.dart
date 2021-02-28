import 'dart:async';

final StreamController<String> _controller = StreamController<String>();

class InmemoryAuth {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('email: $email, password: $password');
    }

    _controller.add(email);
  }

  Future<void> signOut() async {
    _controller.add('');
  }

  Stream<String> get authStateChanges => _controller.stream;
}
