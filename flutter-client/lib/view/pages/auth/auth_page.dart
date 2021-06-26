import 'package:flutter/material.dart';
import 'package:workrec/repositories/auth/auth_repo.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key, required this.viewModel}) : super(key: key);

  final AuthViewModel viewModel;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
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
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: widget.viewModel.onChangeEmail,
                validator: (_) => widget.viewModel.validateEmail()
                    ? null
                    : 'メールアドレスを入力してください',
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(labelText: 'パスワード'),
                onChanged: widget.viewModel.onChangePassword,
                validator: (_) => widget.viewModel.validatePassword()
                    ? null
                    : 'パスワードを入力してください',
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => widget.viewModel.signIn(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: Text(
                    'ログイン',
                    style: Theme.of(context).textTheme.button!.apply(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthViewModel {
  final AuthRepo repo;
  String _email = '';
  String _password = '';

  AuthViewModel({required this.repo});

  Future<void> signIn() async {
    if (!validateEmail() || !validatePassword()) {
      return;
    }

    await repo.signInWithEmailAndPassword(
      email: _email,
      password: _password,
    );
  }

  void onChangeEmail(String email) {
    _email = email;
  }

  void onChangePassword(String password) {
    _password = password;
  }

  bool validateEmail() => _email.isNotEmpty;
  bool validatePassword() => _password.isNotEmpty;
}
