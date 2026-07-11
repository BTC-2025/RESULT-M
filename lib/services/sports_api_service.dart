import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'dart:async' as dart_async;

// ─── Dio Factory ──────────────────────────────────────────────────────────────
Dio _createDio(String baseUrl, {String? headerKey, String? headerValue, String? queryApiKey}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  if (headerKey != null && headerValue != null) {
    dio.options.headers[headerKey] = headerValue;
  }
  if (queryApiKey != null) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['apikey'] = queryApiKey;
        return handler.next(options);
      },
    ));
  }
  return dio;
}

// ─── Service Provider ─────────────────────────────────────────────────────────
final sportsApiServiceProvider = Provider<SportsApiService>((ref) {
  final sportsApiKey = dotenv.env['SPORTSRC_V2_KEY'] ?? 'c9dbeff1fb6ae65f923d43a1705f2f6f';
  final cricApiKey = dotenv.env['CRIC_API_KEY'] ?? '';
  return SportsApiService(
    footballDio: _createDio('https://api.sportsrc.org/v2', headerKey: 'X-API-KEY', headerValue: sportsApiKey),
    cricDio: _createDio('https://api.cricapi.com/v1', queryApiKey: cricApiKey),
  );
});

// ─── Cricket Providers ────────────────────────────────────────────────────────
/// Fetches current/recent matches (matchStarted=true) from /currentMatches
final currentCricketMatchesProvider = FutureProvider<List<CricketMatch>>((ref) async {
  return ref.watch(sportsApiServiceProvider).fetchCurrentCricketMatches();
});

/// Fetches upcoming matches (matchStarted=false) from /matches
final upcomingCricketMatchesProvider = FutureProvider<List<CricketMatch>>((ref) async {
  return ref.watch(sportsApiServiceProvider).fetchUpcomingCricketMatches();
});

/// Combined: current + upcoming, deduplicated
final allCricketMatchesProvider = FutureProvider<List<CricketMatch>>((ref) async {
  final current = await ref.watch(sportsApiServiceProvider).fetchCurrentCricketMatches();
  final upcoming = await ref.watch(sportsApiServiceProvider).fetchUpcomingCricketMatches();
  final seen = <String>{};
  final all = <CricketMatch>[];
  for (final m in [...current, ...upcoming]) {
    if (seen.add(m.id)) all.add(m);
  }
  return all;
});

final cricketMatchInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, matchId) async {
  return ref.watch(sportsApiServiceProvider).fetchCricketMatchInfo(matchId);
});

// ─── Football Providers ───────────────────────────────────────────────────────
FootballMatch _createMockFootballMatch() {
  return FootballMatch(
    id: 'football_demo',
    title: 'London Derby (Mock)',
    teamHome: 'Arsenal',
    teamAway: 'Chelsea',
    teamHomeLogo: '',
    teamAwayLogo: '',
    scoreHome: 2,
    scoreAway: 1,
    statusShort: 'inprogress',
    statusLong: 'Second Half - 72\'',
    displayScoreStr: '2 - 1',
    leagueName: 'Premier League',
    leagueLogo: '',
    leagueCountry: 'England',
    round: 'Matchday 32',
    date: DateTime.now().subtract(const Duration(minutes: 72)),
  );
}

final FutureProvider<List<FootballMatch>> liveFootballProvider = FutureProvider<List<FootballMatch>>((ref) async {
  // Auto-refresh live matches every 60 seconds
  final timer = dart_async.Timer(const Duration(seconds: 60), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());

  try {
    final matches = await ref.watch(sportsApiServiceProvider).fetchFootballMatchesByStatus('inprogress');
    if (matches.isEmpty) {
      return [_createMockFootballMatch()];
    }
    // Prepend or add the mock match for testing
    return [_createMockFootballMatch(), ...matches];
  } catch (e) {
    developer.log('Error fetching live football matches, using mock: $e');
    return [_createMockFootballMatch()];
  }
});

final upcomingFootballProvider = FutureProvider<List<FootballMatch>>((ref) async {
  return ref.watch(sportsApiServiceProvider).fetchUpcomingFootballMatches();
});

final previousFootballProvider = FutureProvider<List<FootballMatch>>((ref) async {
  return ref.watch(sportsApiServiceProvider).fetchPreviousFootballMatches();
});

final todayFootballProvider = FutureProvider<List<FootballMatch>>((ref) async {
  return ref.watch(sportsApiServiceProvider).fetchTodayFootballMatches();
});

final footballMatchDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, fixtureId) async {
  return ref.watch(sportsApiServiceProvider).fetchFootballMatchDetail(fixtureId);
});

// Deprecated or premium endpoints stubbed out
final footballMatchStatsProvider = FutureProvider.family<List<dynamic>?, String>((ref, fixtureId) async {
  return null;
});

final footballMatchLineupsProvider = FutureProvider.family<List<dynamic>?, String>((ref, fixtureId) async {
  return null;
});

final footballMatchEventsProvider = FutureProvider.family<List<dynamic>?, String>((ref, fixtureId) async {
  return null;
});

// ─── NBA Providers ────────────────────────────────────────────────────────────
/// NBA live games — returns an empty list until an NBA API is integrated.
final liveNBAProvider = FutureProvider<List<FootballMatch>>((ref) async {
  return [];
});

// ─── Service Class ────────────────────────────────────────────────────────────
class SportsApiService {
  final Dio footballDio;
  final Dio cricDio;

  SportsApiService({required this.footballDio, required this.cricDio});

  // ─── Cricket ───────────────────────────────────────────────────────────────

  /// Fetches matches that have started (live + recently ended) from /currentMatches
  Future<List<CricketMatch>> fetchCurrentCricketMatches() async {
    try {
      final response = await cricDio.get('/currentMatches', queryParameters: {'offset': 0});
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'] ?? [];
        developer.log('Cricket current matches count: ${data.length}');
        return data.map((r) => CricketMatch.fromJson(r)).toList();
      }
      developer.log('Cricket current error status: ${response.data['status']} msg: ${response.data['reason']}');
      return [];
    } catch (e) {
      developer.log('Cricket currentMatches Error: $e');
      rethrow;
    }
  }

  /// Fetches upcoming scheduled matches from /matches
  Future<List<CricketMatch>> fetchUpcomingCricketMatches() async {
    try {
      final response = await cricDio.get('/matches', queryParameters: {'offset': 0});
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'] ?? [];
        // /matches returns upcoming, filter only truly not started
        final upcoming = data
            .map((r) => CricketMatch.fromJson(r))
            .where((m) => !m.matchStarted && !m.matchEnded)
            .toList();
        developer.log('Cricket upcoming matches count: ${upcoming.length}');
        return upcoming;
      }
      developer.log('Cricket matches error: ${response.data['status']}');
      return [];
    } catch (e) {
      developer.log('Cricket Upcoming Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCricketMatchInfo(String matchId) async {
    try {
      final response = await cricDio.get('/match_info', queryParameters: {'id': matchId});
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      developer.log('Cricket Match Info Error: $e');
      return null;
    }
  }

  // ─── Football ──────────────────────────────────────────────────────────────

  Future<List<FootballMatch>> _parseFootballMatches(Response response) async {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'SportSRC API Error');
      }
      final List leagues = data['data'] ?? [];
      final List<FootballMatch> allMatches = [];
      for (var leagueData in leagues) {
        String leagueName = leagueData['league']?['name'] ?? '';
        if (leagueName.toLowerCase() == 'uncategorized') {
          leagueName = 'International Friendlies';
        }
        final leagueLogo = leagueData['league']?['logo'] ?? '';
        final leagueCountry = leagueData['league']?['country'] ?? '';
        final matchesList = leagueData['matches'] as List? ?? [];
        
        for (var m in matchesList) {
          allMatches.add(FootballMatch.fromJson(m, leagueName, leagueLogo, leagueCountry));
        }
      }
      return allMatches;
    }
    throw Exception('Football fetch error: ${response.statusCode}');
  }

  Future<List<FootballMatch>> fetchFootballMatchesByStatus(String status) async {
    try {
      final response = await footballDio.get('/', queryParameters: {'type': 'matches', 'sport': 'football', 'status': status});
      return await _parseFootballMatches(response);
    } catch (e) {
      developer.log('Football matches Error: $e');
      rethrow;
    }
  }

  Future<List<FootballMatch>> fetchTodayFootballMatches() async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final response = await footballDio.get('/', queryParameters: {'type': 'matches', 'sport': 'football', 'date': today});
      return await _parseFootballMatches(response);
    } catch (e) {
      developer.log('Football Today Error: $e');
      rethrow;
    }
  }

  Future<List<FootballMatch>> fetchUpcomingFootballMatches() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T').first;
      final response = await footballDio.get('/', queryParameters: {'type': 'matches', 'sport': 'football', 'date': tomorrow});
      return await _parseFootballMatches(response);
    } catch (e) {
      developer.log('Football Upcoming Error: $e');
      rethrow;
    }
  }

  Future<List<FootballMatch>> fetchPreviousFootballMatches() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;
      final response = await footballDio.get('/', queryParameters: {'type': 'matches', 'sport': 'football', 'date': yesterday});
      return await _parseFootballMatches(response);
    } catch (e) {
      developer.log('Football Previous Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchFootballMatchDetail(String fixtureId) async {
    try {
      final response = await footballDio.get('/', queryParameters: {'type': 'detail', 'id': fixtureId});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      developer.log('Football Detail Error: $e');
      return null;
    }
  }
}

// ─── Cricket Models ───────────────────────────────────────────────────────────
class CricketTeamInfo {
  final String name;
  final String shortname;
  final String img;

  CricketTeamInfo({required this.name, required this.shortname, required this.img});

  factory CricketTeamInfo.fromJson(Map<String, dynamic> json) {
    return CricketTeamInfo(
      name: json['name'] ?? '',
      shortname: json['shortname'] ?? '',
      img: json['img'] ?? '',
    );
  }
}

class CricketScore {
  final int runs;
  final int wickets;
  final double overs;
  final String inning;

  CricketScore({required this.runs, required this.wickets, required this.overs, required this.inning});

  factory CricketScore.fromJson(Map<String, dynamic> json) {
    return CricketScore(
      runs: (json['r'] ?? 0) as int,
      wickets: (json['w'] ?? 0) as int,
      overs: ((json['o'] ?? 0) as num).toDouble(),
      inning: json['inning'] ?? '',
    );
  }

  String get display => '$runs/$wickets (${overs.toStringAsFixed(1)})';
}

class CricketMatch {
  final String id;
  final String name;
  final String matchType;
  final String status;
  final String venue;
  final DateTime date;
  final List<String> teams;
  final List<CricketTeamInfo> teamInfo;
  final List<CricketScore> score;
  final bool matchStarted;
  final bool matchEnded;
  final String seriesId;

  CricketMatch({
    required this.id,
    required this.name,
    required this.matchType,
    required this.status,
    required this.venue,
    required this.date,
    required this.teams,
    required this.teamInfo,
    required this.score,
    required this.matchStarted,
    required this.matchEnded,
    required this.seriesId,
  });

  bool get isWomens => name.toLowerCase().contains('women');
  bool get isMens => !isWomens;

  String get teamA => teams.isNotEmpty ? teams[0] : 'TBA';
  String get teamB => teams.length > 1 ? teams[1] : 'TBA';

  String? get teamAImg => teamInfo.isNotEmpty ? teamInfo[0].img : null;
  String? get teamBImg => teamInfo.length > 1 ? teamInfo[1].img : null;

  String? get teamAShort => teamInfo.isNotEmpty ? teamInfo[0].shortname : null;
  String? get teamBShort => teamInfo.length > 1 ? teamInfo[1].shortname : null;

  CricketScore? get score1 => score.isNotEmpty ? score[0] : null;
  CricketScore? get score2 => score.length > 1 ? score[1] : null;

  String get matchTypeLabel {
    switch (matchType.toLowerCase()) {
      case 't20': return 'T20';
      case 'odi': return 'ODI';
      case 'test': return 'Test';
      default: return matchType.toUpperCase();
    }
  }

  factory CricketMatch.fromJson(Map<String, dynamic> json) {
    List<CricketScore> scores = [];
    if (json['score'] is List) {
      scores = (json['score'] as List)
          .map((s) => CricketScore.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    List<CricketTeamInfo> teamInfoList = [];
    if (json['teamInfo'] is List) {
      teamInfoList = (json['teamInfo'] as List)
          .map((t) => CricketTeamInfo.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return CricketMatch(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      matchType: json['matchType'] ?? '',
      status: json['status'] ?? '',
      venue: json['venue'] ?? '',
      date: DateTime.tryParse(json['dateTimeGMT'] ?? '') ?? DateTime.now(),
      teams: List<String>.from(json['teams'] ?? []),
      teamInfo: teamInfoList,
      score: scores,
      matchStarted: json['matchStarted'] ?? false,
      matchEnded: json['matchEnded'] ?? false,
      seriesId: json['series_id'] ?? '',
    );
  }
}

// ─── Football Models ──────────────────────────────────────────────────────────
class FootballMatch {
  final String id;
  final String title;
  final String teamHome;
  final String teamAway;
  final String teamHomeLogo;
  final String teamAwayLogo;
  final int? scoreHome;
  final int? scoreAway;
  final String statusShort;
  final String statusLong;
  final String displayScoreStr;
  final String leagueName;
  final String leagueLogo;
  final String leagueCountry;
  final String round;
  final DateTime date;

  FootballMatch({
    required this.id,
    required this.title,
    required this.teamHome,
    required this.teamAway,
    required this.teamHomeLogo,
    required this.teamAwayLogo,
    this.scoreHome,
    this.scoreAway,
    required this.statusShort,
    required this.statusLong,
    required this.displayScoreStr,
    required this.leagueName,
    required this.leagueLogo,
    required this.leagueCountry,
    required this.round,
    required this.date,
  });

  bool get isLive => statusShort == 'inprogress';
  bool get isFinished => statusShort == 'finished';
  bool get isUpcoming => statusShort == 'scheduled' || statusShort == 'notstarted';

  String get displayScore => isUpcoming ? 'vs' : displayScoreStr;

  String get displayStatus {
    return statusLong;
  }

  factory FootballMatch.fromJson(Map<String, dynamic> json, String lName, String lLogo, String lCountry) {
    int timestamp = json['timestamp'] ?? 0;
    if (timestamp == 0 && json['date'] != null) {
      timestamp = json['date']; // Sometimes it's date
    }

    return FootballMatch(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      teamHome: json['teams']?['home']?['name'] ?? 'Home',
      teamAway: json['teams']?['away']?['name'] ?? 'Away',
      teamHomeLogo: json['teams']?['home']?['badge'] ?? '',
      teamAwayLogo: json['teams']?['away']?['badge'] ?? '',
      scoreHome: json['score']?['current']?['home'],
      scoreAway: json['score']?['current']?['away'],
      statusShort: json['status'] ?? '',
      statusLong: json['status_detail'] ?? '',
      displayScoreStr: json['score']?['display'] ?? '0-0',
      leagueName: lName,
      leagueLogo: lLogo,
      leagueCountry: lCountry,
      round: json['round'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }
}
