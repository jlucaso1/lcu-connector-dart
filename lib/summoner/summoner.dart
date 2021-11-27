import 'package:lcu_connector/lcu.dart';

class Summoner {
  int? accountId;
  String? displayName;
  String? internalName;
  bool? nameChangeFlag;
  String? puuid;
  int? profileIconId;
  int? summonerId;
  int? summonerLevel;
  int? xpSinceLastLevel;
  int? xpUntilNextLevel;
  Summoner.fromJson(Map<String, dynamic> json) {
    accountId = json["accountId"];
    displayName = json["displayName"];
    internalName = json["internalName"];
    nameChangeFlag = json["nameChangeFlag"];
    puuid = json["puuid"];
    profileIconId = json["profileIconId"];
    summonerId = json["summonerId"];
    summonerLevel = json["summonerLevel"];
    xpSinceLastLevel = json["xpSinceLastLevel"];
    xpUntilNextLevel = json["xpUntilNextLevel"];
  }
}

class RerollInformation {
  late int currentPoints;
  late int maxRolls;
  late int numberOfRolls;
  late int pointsCostToRoll;
  late int pointsToReroll;
}

class SummonerManager {
  LcuApi client;
  final String baseUrl = "/lol-summoner/v1";
  SummonerManager(this.client);
  Future<Summoner> get currentSummoner {
    var res = client.request(HttpMethod.GET, "$baseUrl/current-summoner");
    return res.then<Summoner>((s) {
      return Summoner.fromJson(s);
    });
  }
}
