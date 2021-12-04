import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/websocket.dart';

main() async {
  var credentials = await authenticate();
  var ws = await connect(credentials);

  ws.on('/lol-matchmaking/v1/search', (argument) {
    print(argument);
  });
}
