import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedItem {
  final String datasetId;
  final String datasetName;
  final String domainType;
  final DateTime viewedAt;

  RecentlyViewedItem({
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'datasetId': datasetId,
        'datasetName': datasetName,
        'domainType': domainType,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedItem(
      datasetId: json['datasetId'] as String,
      datasetName: json['datasetName'] as String,
      domainType: json['domainType'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }
}

class RecentlyViewedNotifier extends StateNotifier<List<RecentlyViewedItem>> {
  static const _key = 'recently_viewed_results';

  RecentlyViewedNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final history = jsonList
            .map((e) => RecentlyViewedItem.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Sort by newest first
        history.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
        state = history;
      } catch (_) {
        // If parsing fails, just keep empty state
        state = [];
      }
    }
  }

  Future<void> _saveHistory(List<RecentlyViewedItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addView(String datasetId, String datasetName, String domainType) async {
    // Remove existing entry for the same dataset if it exists to bring it to top
    final updatedList = state.where((item) => item.datasetId != datasetId).toList();
    
    // Add to top
    updatedList.insert(
      0,
      RecentlyViewedItem(
        datasetId: datasetId,
        datasetName: datasetName,
        domainType: domainType,
        viewedAt: DateTime.now(),
      ),
    );

    // Keep only top 20
    if (updatedList.length > 20) {
      updatedList.removeLast();
    }

    state = updatedList;
    await _saveHistory(updatedList);
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<RecentlyViewedItem>>(
  (ref) => RecentlyViewedNotifier(),
);
