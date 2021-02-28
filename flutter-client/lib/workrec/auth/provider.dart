import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

class AuthProvider extends StatelessWidget {
  final Widget Function(BuildContext context, Auth auth, String userId) builder;
  final Auth auth;
  AuthProvider({
    Key? key,
    required this.auth,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>.value(
      initialData: '',
      value: auth.watchAuthState(),
      child: Consumer<String>(
        builder: (context, value, _) => builder(context, auth, value),
      ),
    );
  }
}
