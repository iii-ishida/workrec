import 'dart:async';

final StreamController<String> _controller = StreamController<String>();

class InmemoryAuth {
  Future<bool> signIn(String userId, String password) async {
    if (userId.isEmpty || password.isEmpty) {
      return false;
    }

    _controller.add(userId);

    return true;
  }

  Future<bool> signOut() async {
    _controller.add('');

    return true;
  }

  Stream<String> watchAuthState() => _controller.stream;
}
