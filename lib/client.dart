import 'dart:async';
import 'dart:io';

import 'package:event_listener/event_listener.dart';
import 'package:lcu_connector/authentication.dart';

class LeagueClient extends EventListener {
  var _isListening = false;
  Credentials? credentials;
  final int poolInterval = 2500;

  LeagueClient(this.credentials);

  start() async {
    if (!_isListening) {
      _isListening = true;

      if (!processExists(credentials!.pid)) {
        // Invalidated credentials or no LeagueClientUx process, fail
        throw new Exception('No LeagueClientUx process');
      }

      this.tryEmit('connect', credentials);

      onTick();
    }
  }

  stop() {
    _isListening = false;
  }

  onTick() async {
    if (_isListening) {
      if (credentials != null) {
        if (!processExists(credentials!.pid)) {
          // No such process, emit disconnect and
          // invalidate credentials
          this.tryEmit('disconnect', null);
          this.credentials = null;
          // Re-queue onTick to listen for credentials
          this.onTick();
        } else {
          Timer(Duration(seconds: poolInterval), () => onTick());
        }
      } else {
        print('Connected to LeagueClientUx');
        var credentials = await authenticate();
        this.credentials = credentials;
        this.tryEmit('connect', credentials);
        Timer(Duration(seconds: poolInterval), () => onTick());
      }
    }
  }
}

bool processExists(int pid) {
  var result = Process.runSync(
    'cmd',
    ["/C", "WMIC PROCESS WHERE ProcessId=$pid GET CommandLine"],
    runInShell: true,
  );
  // print(result.stdout);
  return result.stdout != "";
}
