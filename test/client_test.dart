import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/client.dart';
import 'package:test/test.dart';

void main() async {
  test('new request test', () async {
    var credentials = await authenticate();
    var client = new LeagueClient(credentials);

    client.on('connect', (argument) {
      print('connected');
    });
    client.on('disconnect', (argument) {
      print('disconnected');
    });

    client.start();
  });
}
