import 'dart:async';
import 'dart:io';

final portRegex = new RegExp(
  r'--app-port=([0-9]+)',
);
final tokenRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
final installPathRegex = new RegExp(r'--install-directory=(.+?)"');

class Authentication {
  late String? token;
  late String? port;
  late String? installPath;
  bool isRunning = false;

  Authentication() {}

  Future<bool> CheckLolRunning() async {
    var result = await Process.run(
      'cmd',
      ["/C", "WMIC PROCESS WHERE name='LeagueClientUx.exe' GET CommandLine"],
      runInShell: true,
    );
    if (result.stderr != "") {
      this.port = null;
      this.token = null;
      this.installPath = null;
      isRunning = false;
      return false;
    }
    var port = portRegex.firstMatch(result.stdout)!.group(1)!;
    var token = tokenRegex.firstMatch(result.stdout)!.group(1)!;
    var installPath = installPathRegex.firstMatch(result.stdout)!.group(1)!;

    this.token = token;
    this.port = port;
    this.installPath = installPath;
    isRunning = true;
    return true;
  }

  String get wsFullURL {
    return 'wss://riot:${this.token}@127.0.0.1:${this.port}';
  }

  String get baseUrl {
    return "https://127.0.0.1:${port}";
  }
}
