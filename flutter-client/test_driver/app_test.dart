import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Workrec App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    group('未ログイン', () {
      test('ログイン画面が表示されること', () async {
        expect(await driver.getText(const ByText('Login')), isNotNull);
      });
    });
  });
}
