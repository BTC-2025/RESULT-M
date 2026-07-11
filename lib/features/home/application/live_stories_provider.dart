import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/feed_post_model.dart';
import '../../../../services/sports_api_service.dart';

final liveStoriesProvider = Provider<List<LiveStory>>((ref) {
  final liveFootballAsync = ref.watch(liveFootballProvider);
  final liveCricketAsync = ref.watch(currentCricketMatchesProvider);
  
  List<LiveStory> allStories = [];

  String getTeamAbbr(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].length >= 3 ? words[0].substring(0, 3).toUpperCase() : words[0].toUpperCase();
    }
    final abbr = words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join('');
    return abbr.length > 3 ? abbr.substring(0, 3) : abbr;
  }

  liveCricketAsync.whenData((matches) {
    for (final m in matches.where((x) => x.matchStarted && !x.matchEnded).toList().reversed) {
      final tA = m.teamAShort?.isNotEmpty == true ? m.teamAShort! : getTeamAbbr(m.teamA);
      final tB = m.teamBShort?.isNotEmpty == true ? m.teamBShort! : getTeamAbbr(m.teamB);
      allStories.insert(0, LiveStory(
        id: 'cric_${m.id}',
        label: '$tA vs $tB',
        imageUrl: m.teamAImg,
        isLive: true,
        domainType: 'CRICKET',
        payload: m,
      ));
    }
  });

  liveFootballAsync.whenData((matches) {
    for (final m in matches.where((x) => x.isLive).toList().reversed) {
      final tA = getTeamAbbr(m.teamHome);
      final tB = getTeamAbbr(m.teamAway);
      allStories.insert(0, LiveStory(
        id: 'foot_${m.id}',
        label: '$tA vs $tB',
        imageUrl: m.teamHomeLogo,
        isLive: true,
        domainType: 'FOOTBALL',
        payload: m,
      ));
    }
  });

  return allStories;
});
