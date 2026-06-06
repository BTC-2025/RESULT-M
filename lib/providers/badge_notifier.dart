import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class BadgeState {
  final int unreadComplaints;
  final bool hasActivePolls;

  BadgeState({this.unreadComplaints = 0, this.hasActivePolls = false});

  BadgeState copyWith({int? unreadComplaints, bool? hasActivePolls}) {
    return BadgeState(
      unreadComplaints: unreadComplaints ?? this.unreadComplaints,
      hasActivePolls: hasActivePolls ?? this.hasActivePolls,
    );
  }
}

class BadgeNotifier extends Notifier<BadgeState> {
  late ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _lastVisitKey = 'last_visit_complaints';

  @override
  BadgeState build() {
    _apiService = ref.watch(apiServiceProvider);
    Future.microtask(checkBadges);
    return BadgeState();
  }

  Future<void> checkBadges() async {
    try {
      // 1. Check Complaints
      final lastVisitStr = await _storage.read(key: _lastVisitKey);
      DateTime? lastVisit;
      if (lastVisitStr != null) {
        lastVisit = DateTime.tryParse(lastVisitStr);
      }

      final complaintsData = await _apiService.fetchComplaints(
        sort: 'new',
        page: 0,
        size: 5,
      );

      int unreadCount = 0;
      if (lastVisit != null) {
        for (var c in complaintsData) {
          final createdAt = DateTime.parse(c['createdAt']);
          if (createdAt.isAfter(lastVisit)) {
            unreadCount++;
          }
        }
      } else {
        // First time, assume all recent are unread or just set a max
        unreadCount = complaintsData.length;
      }

      // 2. Check Active Polls
      final votesData = await _apiService.fetchVoteBoxes(page: 0, size: 1);
      final hasPolls = votesData.isNotEmpty;

      state = state.copyWith(
        unreadComplaints: unreadCount,
        hasActivePolls: hasPolls,
      );
    } catch (e) {
      // Ignore errors for badges
    }
  }

  Future<void> markComplaintsRead() async {
    await _storage.write(
      key: _lastVisitKey,
      value: DateTime.now().toIso8601String(),
    );
    state = state.copyWith(unreadComplaints: 0);
  }
}

final badgeProvider = NotifierProvider<BadgeNotifier, BadgeState>(
  BadgeNotifier.new,
);
