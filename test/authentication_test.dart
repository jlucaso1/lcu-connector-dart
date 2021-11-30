import 'package:lcu_connector/authentication.dart';
import 'package:test/test.dart';

void main() async {
  test('try authenticate with client open', () async {
    var authentication = Authentication();
    var tryCount = 0;
    await Future.doWhile(() async {
      var result = await authentication.CheckLolRunning();
      if (!result) {
        print("Lol client not running... tryCount: $tryCount");
        await Future.delayed(Duration(seconds: 2));
        tryCount++;
        if (tryCount >= 5) {
          throw Exception("Lol client not running");
        }
      }
      return !result;
    });
  });
}
