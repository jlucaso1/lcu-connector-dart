import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/websocket.dart';
import 'package:test/test.dart';

void main() async {
  test('try authenticate with client open', () async {
    var credentials = await authenticate();
    await connect(credentials);
  });
}
