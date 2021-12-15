import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';

import './widgets/auth/auth_page.dart';
import './widgets/auth/user_id_notifier.dart';
import './widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authClient = AuthClient();
  late final userIdNotifier = UserIdNotifier(authClient);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserIdNotifier>.value(
      value: userIdNotifier,
      child: MaterialApp.router(
        title: 'Workrec',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
      ),
    );
  }

  static const _signInPath = '/signIn';
  late final _router = GoRouter(
      routes: [
        ...Home.routes,
        GoRoute(
          path: _signInPath,
          builder: (context, state) => AuthPage(
            viewModel: AuthViewModel(authClient: authClient),
          ),
        ),
      ],
      redirect: (state) {
        final userId = userIdNotifier.value.id;
        final loggedIn = userId.isNotEmpty;
        final goingToLogin = state.location == _signInPath;

        if (!loggedIn && !goingToLogin) return _signInPath;
        if (loggedIn && goingToLogin) return '/';

        return null;
      },
      refreshListenable: userIdNotifier,
      navigatorBuilder: (context, child) {
        return userIdNotifier.provider(
          child: child,
        );
      });
}
