library lcu;

import 'dart:convert';
import "dart:io";
import 'dart:async';
import 'package:event_listener/event_listener.dart';
import 'package:lcu_connector/event_response.dart';
import 'package:lcu_connector/summoner/summoner.dart';

final portRegex = new RegExp(
  r'--app-port=([0-9]+)',
);
final tokenRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
final installPathRegex = new RegExp(r'--install-directory=(.+?)"');

class LcuApi {
  late String port;
  String? token;
  final String host = "127.0.0.1";
  late String installPath;
  final EventListener events = new EventListener();
  String username = "riot";
  late SummonerManager summonerManager;
  late HttpClient client;
  late WebSocket _socket;

  String get fullToken {
    return "${username}:${token}";
  }

  String get baseUrl {
    return "https://127.0.0.1:${port}";
  }

  LcuApi() {
    client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    start();
  }
  start() async {
    HttpOverrides.global = new MyHttpOverrides();
    try {
      await loadProcess();
      await loadWebSocket();
      this.events.emit('connected', this);
    } catch (e) {
      print(e);
    }
  }

  loadProcess() async {
    var result = await Process.run(
      'cmd',
      ["/C", "WMIC PROCESS WHERE name='LeagueClientUx.exe' GET CommandLine"],
      runInShell: true,
    );
    if (result.stderr != "") {
      throw new Exception('League of legends is not running!');
    }
    port = portRegex.firstMatch(result.stdout)!.group(1)!;
    token = tokenRegex.firstMatch(result.stdout)!.group(1)!;
    installPath = installPathRegex.firstMatch(result.stdout)!.group(1)!;
    this.summonerManager = new SummonerManager(this);
  }

  loadWebSocket() async {
    _socket = await WebSocket.connect(
        'wss://${this.fullToken}@127.0.0.1:${this.port}');
    _socket.listen((event) {
      try {
        List<dynamic> dataDecoded = json.decode(event);
        Map<String, dynamic> data = dataDecoded[2];
        EventResponse<dynamic> evResponse = EventResponse.fromJson(data);
        if (this.events.events.containsKey(evResponse.uri)) {
          this.events.emit(evResponse.uri, evResponse);
        }
      } catch (_) {}
    });
    _socket.add(json.encode([5, 'OnJsonApiEvent']));
  }

  Future<T> request<T>(HttpMethod method, String path, [String? body]) async {
    bool hasBody = false;

    Future<HttpClientRequest> Function(Uri) fn;
    switch (method) {
      case HttpMethod.GET:
        fn = client.getUrl;
        break;
      case HttpMethod.PUT:
        fn = client.putUrl;
        hasBody = true;
        break;
      case HttpMethod.POST:
        fn = client.postUrl;
        hasBody = true;
        break;
      case HttpMethod.DELETE:
        fn = client.deleteUrl;
        break;
    }
    var req = await fn(Uri.parse("$baseUrl$path"))
      ..headers.add(HttpHeaders.acceptHeader, "*/*")
      ..headers.add(HttpHeaders.authorizationHeader,
          "Basic " + base64Encode(utf8.encode('$username:$token')));
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

    return jsonDecode(await completer.future);
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
