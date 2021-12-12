import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';

class AuthProvider extends StatelessWidget {
  final Widget Function(String userId) builder;
  final AuthClient authClient;

  const AuthProvider({
    Key? key,
    required this.authClient,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>(
      create: (_) => authClient.userId,
      initialData: '',
      child: Builder(builder: (context) {
        final userId = context.watch<String>();
        return builder(userId);
      }),
    );
  }
}