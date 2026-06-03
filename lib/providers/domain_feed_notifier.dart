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

class DomainFeedNotifier extends StateNotifier<AsyncValue<List<DomainFeedItem>>> {
  final ApiService _apiService;
  final DomainType _domainType;
  Timer? _pollingTimer;

  DomainFeedNotifier(this._apiService, this._domainType) : super(const AsyncValue.loading()) {
    _fetchFeed();
    if (_domainType == DomainType.sport || _domainType == DomainType.politics) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshSilent();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchFeed() async {
    try {
      state = const AsyncValue.loading();
      final feedItems = await _loadData();
      if (mounted) {
        state = AsyncValue.data(feedItems);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> _refreshSilent() async {
    try {
      final feedItems = await _loadData();
      if (mounted) {
        state = AsyncValue.data(feedItems);
      }
    } catch (e) {
      // Ignore errors on silent refresh to avoid disrupting UI
    }
  }

  Future<void> refresh() async {
    await _fetchFeed();
  }

  Future<List<DomainFeedItem>> _loadData() async {
    // 1. Fetch workspaces by domain
    final String domainName = _domainType.name.toUpperCase();
    final workspaces = await _apiService.fetchWorkspacesByDomain(domainName);
    
    List<DomainFeedItem> feedItems = [];

    // 2. Fetch datasets and records for each workspace
    for (var workspace in workspaces) {
      final workspaceId = workspace['id'] as String;
      final workspaceName = workspace['name'] as String;

      try {
        final datasets = await _apiService.fetchPublishedDatasets(workspaceId);
        
        // Filter out DRAFT and ARCHIVED just to be safe
        final publishedDatasets = datasets.where((d) => d['status'] == 'PUBLISHED').toList();
        
        if (publishedDatasets.isNotEmpty) {
          // Take the first published dataset
          final firstDataset = publishedDatasets.first;
          final datasetId = firstDataset['id'] as String;
          final datasetName = firstDataset['name'] as String;

          // Fetch records for this dataset
          final recordsData = await _apiService.fetchDatasetRecords(datasetId, page: 0, size: 20);
          
          List<Map<String, dynamic>> parsedRecords = [];
          for (var r in recordsData) {
            if (r['data'] != null) {
              parsedRecords.add(r['data'] as Map<String, dynamic>);
            }
          }

          feedItems.add(DomainFeedItem(
            workspaceId: workspaceId,
            workspaceName: workspaceName,
            datasetId: datasetId,
            datasetName: datasetName,
            domainType: _domainType,
            records: parsedRecords,
          ));
        }
      } catch (e) {
        // Skip workspace if error fetching its datasets (don't fail entire feed)
      }
    }

    return feedItems;
  }
}

final domainFeedProvider = StateNotifierProvider.family<DomainFeedNotifier, AsyncValue<List<DomainFeedItem>>, DomainType>((ref, domainType) {
  final apiService = ref.watch(apiServiceProvider);
  return DomainFeedNotifier(apiService, domainType);
});
