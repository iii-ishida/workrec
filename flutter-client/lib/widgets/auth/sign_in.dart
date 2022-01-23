import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/widgets/styles.dart';
import './auth_form.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key, required this.viewModel}) : super(key: key);

  final SignInViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(SpacingUnit.large),
        child: Column(
          children: <Widget>[
            const SizedBox(height: SpacingUnit.medium),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Login',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: SpacingUnit.large),
            AuthForm(
              buttonLabel: 'ログイン',
              onChangedEmail: viewModel.onChangedEmail,
              onChangedPassword: viewModel.onChangedPassword,
              onSubmit: viewModel.signIn,
            ),
            const SizedBox(height: SpacingUnit.large),
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

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  SignInViewModel({required this.authClient});

  void onChangedEmail(String email) => _email = email;
  void onChangedPassword(String password) => _password = password;

  Future<void> signIn() async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await authClient.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
