import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workrec_app/widgets/styles.dart';

class AuthForm extends StatefulWidget {
  final String buttonLabel;
  final ValueChanged<String> onChangedEmail;
  final ValueChanged<String> onChangedPassword;
  final AsyncCallback onSubmit;

  const AuthForm({
    Key? key,
    required this.buttonLabel,
    required this.onChangedEmail,
    required this.onChangedPassword,
    required this.onSubmit,
  }) : super(key: key);

  @override
  createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailContoller = TextEditingController();
  final TextEditingController _passwordContoller = TextEditingController();

  @override
  initState() {
    super.initState();
    _emailContoller.addListener(() {
      widget.onChangedEmail(_emailContoller.text);
    });

    _passwordContoller.addListener(() {
      widget.onChangedPassword(_passwordContoller.text);
    });
  }

  @override
  dispose() {
    _emailContoller.dispose();
    _passwordContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailContoller,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
            validator: (_) =>
                _emailContoller.text.isNotEmpty ? null : 'メールアドレスを入力してください',
          ),
          const SizedBox(height: SpacingUnit.medium),
          TextFormField(
            controller: _passwordContoller,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            decoration: const InputDecoration(labelText: 'パスワード'),
            validator: (_) =>
                _passwordContoller.text.isNotEmpty ? null : 'パスワードを入力してください',
          ),
          const SizedBox(height: SpacingUnit.large),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              await widget.onSubmit();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: SpacingUnit.medium),
              alignment: Alignment.center,
              width: double.infinity,
              child: Text(
                widget.buttonLabel,
                style: Theme.of(context).textTheme.button!.apply(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}