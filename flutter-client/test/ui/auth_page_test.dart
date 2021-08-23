import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workrec/workrec.dart';
import 'package:workrec_app/auth/auth_page.dart';

import 'auth_page_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  group('AuthViewModel', () {
    late MockAuthRepo repo;
    late AuthViewModel model;

    setUp(() {
      repo = MockAuthRepo();
      model = AuthViewModel(repo: repo);
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
      test('email が空の場合は repo.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangeEmail('');
        model.onChangePassword('somepassword');

        model.signIn();

        verifyNever(repo.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('password が空の場合は repo.signInWithEmailAndPassword を実行しないこと', () {
        model.onChangeEmail('test@example.com');
        model.onChangePassword('');

        model.signIn();

        verifyNever(repo.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('email と password が空でない場合は repo.signInWithEmailAndPassword を実行すること',
          () {
        const email = 'test@example.com';
        const password = 'somepassword';
        model.onChangeEmail(email);
        model.onChangePassword(password);

        model.signIn();

        verify(repo.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
      });
    });
  });
}
