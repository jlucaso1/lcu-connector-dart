library lcu;

import 'dart:convert';
import "dart:io";
import 'dart:async';
import 'package:event_listener/event_listener.dart';
import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/event_response.dart';
import 'package:uno/uno.dart';

final portRegex = new RegExp(
  r'--app-port=([0-9]+)',
);
final tokenRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
final installPathRegex = new RegExp(r'--install-directory=(.+?)"');

class LcuApi {
  final EventListener events = new EventListener();
  final Authentication authentication = new Authentication();
  final Uno client = new Uno();
  late WebSocket socket;

  LcuApi() {
    HttpOverrides.global = new MyHttpOverrides();
  }
  start() async {
    try {
      var isRunning = await authentication.CheckLolRunning();
      if (!isRunning) {
        throw new Exception('LOL is not running');
      }
      await loadWebSocket();
      this.events.tryEmit('connected', this);
    } catch (e) {
      throw e;
    }
  }

  loadWebSocket() async {
    socket = await WebSocket.connect(authentication.wsFullURL);
    socket.listen((event) {
      try {
        List<dynamic> dataDecoded = json.decode(event);
        Map<String, dynamic> data = dataDecoded[2];
        EventResponse<dynamic> evResponse = EventResponse.fromJson(data);
        if (this.events.events.containsKey(evResponse.uri)) {
          this.events.tryEmit(evResponse.uri, evResponse);
        }
      } catch (_) {}
    });
    socket.add(json.encode([5, 'OnJsonApiEvent']));
  }

  Future<Response> request(HttpMethod method, String path,
      [dynamic body]) async {
    return await client(
      method: method.toShortString(),
      url: '${authentication.baseUrl}$path',
      headers: {
        'Authorization': "Basic " +
            base64Encode(utf8.encode('riot:${authentication.token}')),
      },
      data: body,
    );
  }
}

enum HttpMethod { PUT, GET, DELETE, POST }

extension ParseToString on HttpMethod {
  String toShortString() {
    return this.toString().split('.').last.toLowerCase();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
