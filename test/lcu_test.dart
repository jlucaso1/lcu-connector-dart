import 'package:lol/lcu.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
    final api = LcuApi("D:/Programs/Riot Games/League of Legends");
    print(api.port);
    final summoner = await api.summonerManager!.currentSummoner;
    print(summoner.xpSinceLastLevel);
  });
}
