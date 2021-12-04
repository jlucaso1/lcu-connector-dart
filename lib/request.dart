import 'dart:convert';
import 'dart:io';

import 'package:lcu_connector/authentication.dart';
import 'package:lcu_connector/utils/http_override.dart';
import 'package:uno/uno.dart';

Future<Response> request(
    HttpMethod method, String path, Credentials credentials,
    [dynamic body]) async {
  HttpOverrides.global = new MyHttpOverrides();
  final Uno client = new Uno();
  var url = 'https://127.0.0.1:${credentials.port}$path';
  print(url);
  return await client(
    method: method.toShortString(),
    url: url,
    headers: {
      'Authorization':
          "Basic " + base64Encode(utf8.encode('riot:${credentials.password}')),
    },
    data: body,
  );
}

enum HttpMethod { PUT, GET, DELETE, POST }

extension ParseToString on HttpMethod {
  String toShortString() {
    return this.toString().split('.').last.toLowerCase();
  }
}
