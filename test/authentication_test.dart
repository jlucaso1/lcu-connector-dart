import 'package:lcu_connector/authentication.dart';
import 'package:test/test.dart';

void main() async {
  test('try authenticate', () async {
    var authentication = Authentication();
    var result = await authentication.CheckLolRunning();
    expect(result, true);
  });
}
