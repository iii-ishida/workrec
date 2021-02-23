import 'package:flutter/material.dart';

typedef _SignInFunc = Future<bool> Function(String email, String password);

class AuthPage extends StatefulWidget {
  AuthPage({Key? key, required this.signIn}) : super(key: key);

  final _SignInFunc signIn;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final ViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = ViewModel(signIn: widget.signIn);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _model.formKey,
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
              controller: _model.emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              validator: (_) =>
                  _model.validateEmail() ? null : 'メールアドレスを入力してください',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _model.passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(labelText: 'パスワード'),
              validator: (_) =>
                  _model.validatePassword() ? null : 'パスワードを入力してください',
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _model.handleSignIn(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

class ViewModel {
  @visibleForTesting
  ViewModel({required this.signIn});

  final _SignInFunc signIn;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleSignIn() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    await signIn(emailController.text, passwordController.text);
  }

  bool validateEmail() => emailController.text.isNotEmpty;
  bool validatePassword() => passwordController.text.isNotEmpty;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
