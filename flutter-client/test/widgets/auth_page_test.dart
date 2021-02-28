import 'package:flutter_test/flutter_test.dart';
import 'package:workrec/widgets/auth_page.dart';

void main() {
  group('AuthPage', () {
    late ViewModel model;

    setUp(() {
      model = ViewModel(signIn: ({required email, required password}) async {});
    });

    test('.validateEmail should be false when the email is empty', () {
      model.emailController.text = '';

      expect(model.validateEmail(), false);
    });

    test('.validateEmail should be true when the email is not empty', () {
      model.emailController.text = 'test@example.com';

      expect(model.validateEmail(), true);
    });

    test('.validatePassword should be false when the password is empty', () {
      model.passwordController.text = '';

      expect(model.validatePassword(), false);
    });

    test('.validatePassword should be true when the password is not empty', () {
      model.passwordController.text = 'somepassword';

      expect(model.validatePassword(), true);
    });
  });
}
