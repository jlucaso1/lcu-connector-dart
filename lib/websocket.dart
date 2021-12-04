// ignore_for_file: close_sinks

import 'dart:convert';
import 'dart:io';

import 'package:event_listener/event_listener.dart';
import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/types/event_response.dart';
import 'package:lcu_connector/utils/http_override.dart';

class LeagueWebSocket extends EventListener {
  final WebSocket _webSocket;
  LeagueWebSocket(this._webSocket) {
    _webSocket.listen((event) {
      try {
        List<dynamic> dataDecoded = json.decode(event);
        Map<String, dynamic> data = dataDecoded[2];
        EventResponse<dynamic> evResponse = EventResponse.fromJson(data);
        if (this.events.containsKey(evResponse.uri)) {
          this.tryEmit(evResponse.uri, evResponse);
        }
      } catch (_) {}
    });
    _webSocket.add(json.encode([5, 'OnJsonApiEvent']));
  }
}

Future<LeagueWebSocket> connect(Credentials credentials) async {
  HttpOverrides.global = new MyHttpOverrides();
  var ws = await WebSocket.connect(
      'wss://riot:${credentials.password}@127.0.0.1:${credentials.port}');
  return LeagueWebSocket(ws);
}
