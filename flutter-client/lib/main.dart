import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/workrec_client/workrec_client.dart';
import './widgets/routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authClient = AuthClient();
  late final authUserNotifier = _AuthUserNotifier(authClient);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_AuthUserNotifier>.value(
      value: authUserNotifier,
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

  late final _router = GoRouter(
      routes: routes,
      redirect: (state) {
        final userId = authUserNotifier.value.id;
        final loggedIn = userId.isNotEmpty;
        final signInLoc = state.namedLocation('signIn');
        final signUpLoc = state.namedLocation('signUp');
        final goingToAuth =
            state.subloc == signInLoc || state.subloc == signUpLoc;

        if (!loggedIn && !goingToAuth) return state.namedLocation('signIn');
        if (loggedIn && goingToAuth) return '/';

        return null;
      },
      refreshListenable: authUserNotifier,
      navigatorBuilder: (context, child) {
        return MultiProvider(
          providers: [
            Provider<AuthClient>.value(
              value: authClient,
            ),
            Provider<WorkrecClient>.value(
              value: WorkrecClient(userId: authUserNotifier.value.id),
            )
          ],
          child: child,
        );
      });
}

class _AuthUserNotifier extends ValueNotifier<AuthUser> {
  final AuthClient authClient;

  _AuthUserNotifier(this.authClient) : super(authClient.currentUser) {
    authClient.userStream.listen((user) {
      value = user;
      notifyListeners();
    });
  }
}
