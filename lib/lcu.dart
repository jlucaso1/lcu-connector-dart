library lcu;

import 'dart:convert';
import "dart:io";
import 'dart:async';
import 'package:lol/summoner/summoner.dart';

class LcuApi {
  int? port;
  String? token;
  final String host = "127.0.0.1";
  String username = "riot";
  SummonerManager? summonerManager;
  HttpClient? client;
  String get fullToken {
    return "$username:$token";
  }

  String get baseUrl {
    return "https://127.0.0.1:$port";
  }

  LcuApi(String leagueLocation) {
    var file = File("$leagueLocation/lockfile");
    var text = file.readAsStringSync();
    var entries = text.split(":");
    port = int.parse(entries[2]);
    token = entries[3];

    client = HttpClient();
    client!.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    summonerManager = new SummonerManager(this);
  }

  Future<T> request<T>(HttpMethod method, String path, [String? body]) async {
    bool hasBody = false;

    Future<HttpClientRequest> Function(Uri) fn;
    switch (method) {
      case HttpMethod.GET:
        fn = client!.getUrl;
        break;
      case HttpMethod.PUT:
        fn = client!.putUrl;
        hasBody = true;
        break;
      case HttpMethod.POST:
        fn = client!.postUrl;
        hasBody = true;
        break;
      case HttpMethod.DELETE:
        fn = client!.deleteUrl;
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
