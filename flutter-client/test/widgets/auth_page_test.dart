import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/widgets/auth_page.dart';

void main() {
  group('AuthPage', () {
    late ViewModel model;

    setUp(() {
      model = ViewModel(signIn: ({required email, required password}) async {});
    });

    group('.validateEmail', () {
      test('email が空の場合は false を返すこと', () {
        model.emailController.text = '';

        expect(model.validateEmail(), false);
      });

      test('email が空でない場合は true を返すこと', () {
        model.emailController.text = 'test@example.com';

        expect(model.validateEmail(), true);
      });
    });

    group('.validatePassword', () {
      test('password が空の場合は false を返すこと', () {
        model.passwordController.text = '';

        expect(model.validatePassword(), false);
      });

      test('password が空でない場合は true を返すこと', () {
        model.passwordController.text = 'somepassword';

        expect(model.validatePassword(), true);
      });
    });
  });
}
