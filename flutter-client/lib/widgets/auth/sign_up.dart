import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/widgets/styles.dart';
import './auth_form.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key, required this.viewModel}) : super(key: key);

  final SignUpViewModel viewModel;

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
                'Sign Up',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const SizedBox(height: SpacingUnit.large),
            AuthForm(
              buttonLabel: 'ユーザー登録',
              onChangedEmail: viewModel.onChangedEmail,
              onChangedPassword: viewModel.onChangedPassword,
              onSubmit: viewModel.createUser,
            ),
            const SizedBox(height: SpacingUnit.large),
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

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  void onChangedEmail(String email) => _email = email;
  void onChangedPassword(String password) => _password = password;

  Future<void> createUser() async {
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await authClient.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
