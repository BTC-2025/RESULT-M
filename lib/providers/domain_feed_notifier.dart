import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../models/domain_model.dart';

class DomainFeedItem {
  final String workspaceId;
  final String workspaceName;
  final String datasetId;
  final String datasetName;
  final DomainType domainType;
  final List<Map<String, dynamic>> records;

  DomainFeedItem({
    required this.workspaceId,
    required this.workspaceName,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
    required this.records,
  });
}

class DomainFeedNotifier extends AsyncNotifier<List<DomainFeedItem>> {
  late ApiService _apiService;
  final DomainType _domainType;
  Timer? _pollingTimer;

  DomainFeedNotifier(this._domainType);

  @override
  Future<List<DomainFeedItem>> build() async {
    _apiService = ref.watch(apiServiceProvider);

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    if (_domainType == DomainType.sport || _domainType == DomainType.politics) {
      _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _refreshSilent();
      });
    }

    return _loadData();
  }

  Future<void> _refreshSilent() async {
    try {
      final feedItems = await _loadData();
      state = AsyncData(feedItems);
    } catch (e) {
      // Ignore errors on silent refresh to avoid disrupting UI
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadData());
  }

  Future<List<DomainFeedItem>> _loadData() async {
    final String domainName = backendDomainTypeFor(_domainType) ?? 'CUSTOM';
    final workspaces = await _apiService.fetchWorkspacesByDomain(domainName);

    return workspaces
        .whereType<Map<String, dynamic>>()
        .map(_workspaceFeedItem)
        .toList();
  }

  DomainFeedItem _workspaceFeedItem(Map<String, dynamic> workspace) {
    final workspaceId = workspace['id']?.toString() ?? '';
    final workspaceName = workspace['name']?.toString() ?? 'Result workspace';

    return DomainFeedItem(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      datasetId: '${workspaceId}_summary',
      datasetName: workspaceName,
      domainType: _domainType,
      records: [_summaryRecord(workspaceName, workspace['description']?.toString())],
    );
  }

  Map<String, dynamic> _summaryRecord(String title, String? description) {
    final subtitle = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Open this workspace to view published result data.';

    switch (_domainType) {
      case DomainType.sport:
        return {
          'team1': title,
          'score1': 'Live',
          'status': subtitle,
        };
      case DomainType.politics:
        return {
          'candidate': title,
          'party': subtitle,
          'votes': 'Live',
          'percentage': '0',
        };
      case DomainType.finance:
        return {
          'symbol': title,
          'name': subtitle,
          'price': 'Live',
          'change': '+0%',
        };
      case DomainType.entertainment:
        return {
          'title': title,
          'metric': 'Live',
        };
      case DomainType.tech:
        return {
          'productName': title,
          'score': 'Live',
        };
      case DomainType.law:
        return {
          'caseTitle': title,
          'court': subtitle,
          'verdict': 'Open',
        };
      case DomainType.academic:
      case DomainType.government:
      case DomainType.hyperLocal:
        return {
          'title': title,
          'details': subtitle,
          'status': 'Published',
        };
    }
  }
}

final domainFeedProvider =
    AsyncNotifierProvider.family<
      DomainFeedNotifier,
      List<DomainFeedItem>,
      DomainType
    >(DomainFeedNotifier.new);
