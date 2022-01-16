import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import './auth_form.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key, required this.viewModel}) : super(key: key);

  final SignUpViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Sign Up',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 32),
            AuthForm(
              buttonLabel: 'ユーザー登録',
              onSubmit: (email, password) =>
                  viewModel.createUser(email, password),
            ),
            const SizedBox(height: 32),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => context.go('/signIn'),
              child: const Text(
                'ログイン',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpViewModel {
  final AuthClient authClient;

  SignUpViewModel({required this.authClient});

  Future<void> createUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await authClient.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
