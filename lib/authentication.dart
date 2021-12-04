import 'dart:async';
import 'dart:io';

final portRegex = new RegExp(
  r'--app-port=([0-9]+)',
);
final tokenRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
final installPathRegex = new RegExp(r'--install-directory=(.+?)"');
final pidRegex = new RegExp(r'--app-pid=([0-9]+)');

class Credentials {
  /// The system port the LCU API is running on
  late int port;

  /// The password for the LCU API
  late String password;

  /// The system process id for the LeagueClientUx process
  late int pid;

  Credentials(this.port, this.password, this.pid);
}

Future<Credentials> authenticate() async {
  // Using powershell
  final portRegex = new RegExp(
    r'--app-port=([0-9]+)',
  );
  final passwordRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');
  final pidRegex = new RegExp(r'--app-pid=([0-9]+)');
  // final installPathRegex = new RegExp(r'--install-directory=(.+?)"');

  var result = await Process.run(
    'powershell',
    [
      "Get-CimInstance -Query \"SELECT * from Win32_Process WHERE name LIKE 'LeagueClientUx.exe'\" | Select-Object CommandLine | fl"
    ],
    runInShell: true,
  );
  // Using CMD
  // var result = await Process.run(
  //   'cmd',
  //   ["/C", "WMIC PROCESS WHERE name='LeagueClientUx.exe' GET CommandLine"],
  //   runInShell: true,
  // );
  try {
    var port = portRegex.firstMatch(result.stdout)!.group(1)!;
    var password = passwordRegex.firstMatch(result.stdout)!.group(1)!;
    var pid = pidRegex.firstMatch(result.stdout)!.group(1)!;

    return new Credentials(int.parse(port), password, int.parse(pid));
  } catch (e) {
    throw new Exception("Could not find LeagueClientUx.exe");
  }
}
