import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workrec/workrec.dart';

class AuthProvider extends StatelessWidget {
  final Widget Function(String userId) builder;
  final AuthRepo repo;

  const AuthProvider({
    Key? key,
    required this.repo,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<String>(
      create: (_) => repo.userId,
      initialData: '',
      child: Builder(builder: (context) {
        final userId = context.watch<String>();
        return builder(userId);
      }),
    );
  }
}
