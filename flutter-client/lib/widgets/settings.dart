import 'package:flutter/material.dart';

import 'package:workrec_app/auth_client/auth_client.dart';

class Settings extends StatelessWidget {
  final SettingsViewModel _viewModel;
  Settings({Key? key, AuthClient? authClient})
      : _viewModel = SettingsViewModel(authClient ?? AuthClient()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(title: const Text('ログアウト'), onTap: _viewModel.signOut),
      const Divider(height: 1, color: Color(0xFFA5A5A5)),
    ]);
  }
}

class SettingsViewModel {
  AuthClient authClient;
  SettingsViewModel(this.authClient);

  Future<void> signOut() async {
    await authClient.signOut();
  }
}
