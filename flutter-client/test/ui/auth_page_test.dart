import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec_app/auth_client/auth_client.dart';
import 'package:workrec_app/widgets/auth/auth_page.dart';

import 'auth_page_test.mocks.dart';

@GenerateMocks([AuthClient])
void main() {
  group('AuthViewModel', () {
    late MockAuthClient client;
    late AuthViewModel model;

    setUp(() {
      client = MockAuthClient();
      model = AuthViewModel(authClient: client);
    });

    group('.validateEmail', () {
      test('email が空の場合は false を返すこと', () {
        model.onChangeEmail('');

        expect(model.validateEmail(), false);
      });

      test('email が空でない場合は true を返すこと', () {
        model.onChangeEmail('test@example.com');

        expect(model.validateEmail(), true);
      });
    });

    group('.validatePassword', () {
      test('password が空の場合は false を返すこと', () {
        model.onChangePassword('');

        expect(model.validatePassword(), false);
      });

      test('password が空でない場合は true を返すこと', () {
        model.onChangePassword('somepassword');

        expect(model.validatePassword(), true);
      });
    });

    group('.signIn', () {
      test('email が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangeEmail('');
        model.onChangePassword('somepassword');

        model.signIn();

        verifyNever(client.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('password が空の場合は client.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangeEmail('test@example.com');
        model.onChangePassword('');

        model.signIn();

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
        model.onChangeEmail(email);
        model.onChangePassword(password);

        model.signIn();

        verify(client.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
      });
    });
  });
}
