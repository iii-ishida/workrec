import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/widgets/auth/sign_in.dart';

class MockAuthClient extends Mock implements AuthClient {}

void main() {
  group('SignInViewModel', () {
    late MockAuthClient client;
    late SignInViewModel model;

    setUp(() {
      client = MockAuthClient();
      model = SignInViewModel(authClient: client);
      when(
        () => client.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    group('.signIn', () {
      test('email が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangedEmail('');
        model.onChangedPassword('somepassword');
        model.signIn();

        verifyNever(() => client.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('password が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangedEmail('test@example.com');
        model.onChangedPassword('');
        model.signIn();

        verifyNever(() => client.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test(
          'email と password が空でない場合は client.signInWithEmailAndPassword を実行すること',
          () {
        const email = 'test@example.com';
        const password = 'somepassword';

        model.onChangedEmail(email);
        model.onChangedPassword(password);
        model.signIn();

        verify(() => client.signInWithEmailAndPassword(
              email: email,
              password: password,
            ));
      });
    });
  });
}
