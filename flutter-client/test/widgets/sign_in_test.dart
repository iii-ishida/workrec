import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/widgets/auth/sign_in.dart';
import 'sign_in_test.mocks.dart';

@GenerateMocks([AuthClient])
void main() {
  group('SignInViewModel', () {
    late MockAuthClient client;
    late SignInViewModel model;

    setUp(() {
      client = MockAuthClient();
      model = SignInViewModel(authClient: client);
    });

    group('.signIn', () {
      test('email が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.signIn('', 'somepassword');

        verifyNever(client.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('password が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.signIn('test@example.com', '');

        verifyNever(client.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test(
          'email と password が空でない場合は client.signInWithEmailAndPassword を実行すること',
          () {
        const email = 'test@example.com';
        const password = 'somepassword';

        model.signIn(email, password);

        verify(client.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
      });
    });
  });
}
