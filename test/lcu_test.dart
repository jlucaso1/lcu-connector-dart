import 'package:lol/lcu.dart';
import 'package:lol/summoner/summoner.dart';
import 'package:test/test.dart';

void main() async {
  test('get connection', () async {
    final api = new LcuApi();
    api.events.on('connected', (argument) async {
      assert(await api.summonerManager.currentSummoner is Summoner);
      assert(argument is LcuApi);
    });
    await Future.delayed(Duration(seconds: 5));
  });
}
