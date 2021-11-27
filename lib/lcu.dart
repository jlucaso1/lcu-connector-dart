library lcu;

import 'dart:convert';
import "dart:io";
import 'dart:async';
import 'package:event_listener/event_listener.dart';
import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/event_response.dart';
// import 'package:lcu_connector/summoner/summoner.dart';

final portRegex = new RegExp(
  r'--app-port=([0-9]+)',
);
final tokenRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
final installPathRegex = new RegExp(r'--install-directory=(.+?)"');

class LcuApi {
  final EventListener events = new EventListener();
  // late SummonerManager summonerManager;
  late HttpClient client;
  late WebSocket socket;
  Authentication authentication = new Authentication();

  LcuApi() {
    client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    HttpOverrides.global = new MyHttpOverrides();
  }
  start() async {
    try {
      await authentication.CheckLolRunning();
      await loadWebSocket();
      this.events.emit('connected', this);
    } catch (e) {
      print(e);
    }
  }

  loadWebSocket() async {
    socket = await WebSocket.connect(authentication.wsURL);
    socket.listen((event) {
      try {
        List<dynamic> dataDecoded = json.decode(event);
        Map<String, dynamic> data = dataDecoded[2];
        EventResponse<dynamic> evResponse = EventResponse.fromJson(data);
        if (this.events.events.containsKey(evResponse.uri)) {
          this.events.emit(evResponse.uri, evResponse);
        }
      } catch (_) {}
    });
    socket.add(json.encode([5, 'OnJsonApiEvent']));
  }

  Future<T?> request<T>(HttpMethod method, String path, [String? body]) async {
    bool hasBody = false;

    Future<HttpClientRequest> Function(Uri) fn;
    switch (method) {
      case HttpMethod.GET:
        fn = client.getUrl;
        break;
      case HttpMethod.PUT:
        fn = client.putUrl;
        break;
      case HttpMethod.POST:
        fn = client.postUrl;
        break;
      case HttpMethod.DELETE:
        fn = client.deleteUrl;
        break;
    }
    if (body != null) {
      hasBody = true;
    }
    var req = await fn(Uri.parse("${authentication.baseUrl}$path"))
      ..headers.add(HttpHeaders.acceptHeader, "*/*")
      ..headers.add(HttpHeaders.authorizationHeader,
          "Basic " + base64Encode(utf8.encode('riot:${authentication.token}')));
    if (hasBody) {
      req.headers.contentLength = body!.length;
      req.headers.contentType = ContentType("application", "json");
      req.write(body);
    }
    var res = await req.close();
    final completer = Completer<String>();
    final contents = StringBuffer();
    res.transform(utf8.decoder).listen((data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));

    var response = await completer.future;
    if (response.isEmpty) {
      return null;
    }

    return jsonDecode(response);
  }
}

enum HttpMethod { PUT, GET, DELETE, POST }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
