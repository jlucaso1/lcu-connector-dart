import 'package:lcu_connector/lcu.dart';

class Summoner {
  final int accountId;
  final String displayName;
  final String internalName;
  final bool nameChangeFlag;
  final String puuid;
  final int profileIconId;
  final int summonerId;
  final int summonerLevel;
  final int xpSinceLastLevel;
  final int xpUntilNextLevel;

  Summoner({
    required this.accountId,
    required this.displayName,
    required this.internalName,
    required this.nameChangeFlag,
    required this.puuid,
    required this.profileIconId,
    required this.summonerId,
    required this.summonerLevel,
    required this.xpSinceLastLevel,
    required this.xpUntilNextLevel,
  });

  factory Summoner.fromJson(Map<String, dynamic> json) {
    return Summoner(
      accountId: json['accountId'],
      displayName: json['displayName'],
      internalName: json['internalName'],
      nameChangeFlag: json['nameChangeFlag'],
      puuid: json['puuid'],
      profileIconId: json['profileIconId'],
      summonerId: json['summonerId'],
      summonerLevel: json['summonerLevel'],
      xpSinceLastLevel: json['xpSinceLastLevel'],
      xpUntilNextLevel: json['xpUntilNextLevel'],
    );
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
