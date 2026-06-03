import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Family provider that creates a unique notifier for each datasetId
final liveDatasetProvider = StateNotifierProvider.family<LiveDatasetNotifier, AsyncValue<List<dynamic>>, String>((ref, datasetId) {
  final apiService = ref.watch(apiServiceProvider);
  return LiveDatasetNotifier(datasetId, apiService);
});

class LiveDatasetNotifier extends StateNotifier<AsyncValue<List<dynamic>>> with WidgetsBindingObserver {
  final String datasetId;
  final ApiService apiService;
  Timer? _timer;
  bool _isPolling = false;

  LiveDatasetNotifier(this.datasetId, this.apiService) : super(const AsyncValue.loading()) {
    WidgetsBinding.instance.addObserver(this);
    _initialFetch();
  }

  void _initialFetch() async {
    try {
      final records = await apiService.fetchDatasetRecords(datasetId);
      if (mounted) {
        state = AsyncValue.data(records);
        _startPolling();
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _silentFetch());
  }

  void _stopPolling() {
    _isPolling = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _silentFetch() async {
    if (!mounted) return;
    try {
      final records = await apiService.fetchDatasetRecords(datasetId);
      if (mounted) {
        // Only update state; no loading spinner
        state = AsyncValue.data(records);
      }
    } catch (e) {
      developer.log('Silent fetch failed for dataset $datasetId: $e');
      // Do not transition to error state if we already have data, just skip this tick
      if (!state.hasValue && mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Manually trigger a refresh right now
  Future<void> refresh() async {
    // If we have no data, show loading state. Otherwise, keep current data and silent fetch.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
      _initialFetch();
    } else {
      await _silentFetch();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _silentFetch(); // Immediately fetch on resume
      _startPolling();
    } else if (appState == AppLifecycleState.paused || appState == AppLifecycleState.inactive) {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
