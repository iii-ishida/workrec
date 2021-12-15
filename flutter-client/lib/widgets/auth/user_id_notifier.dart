import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';

class UserId {
  final String id;
  UserId(this.id);
}

class UserIdNotifier extends ValueNotifier<UserId> {
  final AuthClient authClient;

  UserIdNotifier(this.authClient) : super(UserId(authClient.currentUserId)) {
    authClient.userId.listen((id) {
      value = UserId(id);
      notifyListeners();
    });
  }

  Widget provider({required Widget? child}) {
    return Provider<UserId>.value(
      value: value,
      child: child,
    );
  }
}

String userIdOf(BuildContext context) {
  return context.read<UserId>().id;
}
