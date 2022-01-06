import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import './auth_form.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key, required this.viewModel}) : super(key: key);

  final SignInViewModel viewModel;

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
                'Login',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: 32),
            AuthForm(
              buttonLabel: 'ログイン',
              onSubmit: (email, password) => viewModel.signIn(email, password),
            ),
            const SizedBox(height: 32),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => context.go('/signUp'),
              child: const Text(
                'ユーザー登録',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInViewModel {
  final AuthClient authClient;

  SignInViewModel({required this.authClient});

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await authClient.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
