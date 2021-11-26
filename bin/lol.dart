import 'package:lol/event_response.dart';
import 'package:lol/lcu.dart';
import 'package:lol/summoner/summoner.dart';

main() async {
  final lcu = new LcuApi();
  lcu.events.on('connected', (_) async {
    print("Connected");
    // Get summoner infos
    Summoner mySummoner = await lcu.summonerManager.currentSummoner;
    print(
        'Summoner: ${mySummoner.displayName} | Level: ${mySummoner.summonerLevel}');
    // Listen for queue changes
    lcu.events.on('/lol-matchmaking/v1/search', (message) {
      EventResponse evResponse = message;
      if (evResponse.eventType == 'Create') {
        print('Queue search started');
      } else if (evResponse.eventType == 'Delete') {
        print('Queue search stopped');
      }
    });
  });
  lcu.events.on('error', (message) {
    print(message.toString());
  });
}
