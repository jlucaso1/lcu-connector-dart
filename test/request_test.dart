import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/request.dart';
import 'package:test/test.dart';

void main() async {
  test('try authenticate with client open', () async {
    var credentials = await authenticate();
    var response = await request(
        HttpMethod.GET, '/lol-summoner/v1/current-summoner', credentials);
    expect(response.status, 200);
  });
}
