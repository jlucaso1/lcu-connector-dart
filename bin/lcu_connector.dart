import 'package:lcu_connector/event_response.dart';
import 'package:lcu_connector/lcu.dart';

main() async {
  final lcu = new LcuApi();

  lcu.events.on('connected', (_) async {
    print("Connected");

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

  await lcu.start();
}
