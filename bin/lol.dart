import 'dart:io';

main() async {
  final portRegex = new RegExp(
    r'--app-port=([0-9]+)',
  );
  final passwordRegex = new RegExp(r'--remoting-auth-token=([\w-_]+)');

  // List all files in the current directory in UNIX-like systems.
  var result = await Process.run(
    'cmd',
    ["/C", "WMIC PROCESS WHERE name='LeagueClientUx.exe' GET CommandLine"],
  );
  String? port = portRegex.firstMatch(result.stdout)!.group(1);
  String? password = passwordRegex.firstMatch(result.stdout)!.group(1);
  print('port: $port');
  print('password: $password');
}
