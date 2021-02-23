import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

class AuthProvider extends StatelessWidget {
  final Widget Function(BuildContext context, String userId) builder;
  AuthProvider({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>.value(
      initialData: '',
      value: Auth().watchAuthState(),
      child: Consumer<String>(
        builder: (context, value, _) => builder(context, value),
      ),
    );
  }
}
