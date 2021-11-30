import 'package:lcu_connector/lcu.dart';
import 'package:lcu_connector/summoner/summoner.dart';
import 'package:test/test.dart';

void main() async {
  test('new request test', () async {
    var lcu = LcuApi();
    await lcu.start();
    var result = await lcu
        .request(HttpMethod.GET, '/lol-summoner/v1/current-summoner', {"a": 1});
    var summoner = Summoner.fromJson(result.data);
    expect(summoner.summonerLevel, greaterThan(0));
  });
  test('create new room', () async {
    var lcu = LcuApi();
    await lcu.start();
    var result = await lcu
        .request(HttpMethod.POST, '/lol-lobby/v2/lobby', {"queueId": 420});
    expect(result.data, isNotNull);
  });
}
