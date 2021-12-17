import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'firebase_options.dart';
import './widgets/sign_in.dart';
import './widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(MyApp());
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
      routes: [
        ...Home.routes,
        GoRoute(
          name: 'signIn',
          path: '/signIn',
          builder: (context, state) => SignIn(
            viewModel: SignInViewModel(authClient: authClient),
          ),
        ),
      ],
      redirect: (state) {
        final userId = authUserNotifier.value.id;
        final loggedIn = userId.isNotEmpty;
        final signInLoc = state.namedLocation('signIn');
        final goingToSignIn = state.subloc == signInLoc;

        if (!loggedIn && !goingToSignIn) return state.namedLocation('signIn');
        if (loggedIn && goingToSignIn) return '/';

        return null;
      },
      refreshListenable: authUserNotifier,
      navigatorBuilder: (context, child) {
        return Provider<AuthUser>.value(
          value: authUserNotifier.value,
          child: child,
        );
      });
}
