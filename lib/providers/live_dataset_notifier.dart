import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';
import '../services/api_service.dart';

// Family provider that creates a unique notifier for each datasetId
final liveDatasetProvider =
    AsyncNotifierProvider.family<LiveDatasetNotifier, List<dynamic>, String>(
      LiveDatasetNotifier.new,
    );

class LiveDatasetNotifier extends FamilyAsyncNotifier<List<dynamic>, String>
    with WidgetsBindingObserver {
  late String datasetKey;
  late ApiService apiService;
  Timer? _timer;
  Timer? _streamRefreshDebounce;
  StreamSubscription<String>? _eventSubscription;
  bool _isPolling = false;
  bool _isStreaming = false;
  bool _mounted = true;

  String get datasetId => datasetKey.split('|').first;
  String? get workspaceId {
    final parts = datasetKey.split('|');
    return parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
  }

  Future<String?> _workspaceToken() async {
    final id = workspaceId;
    if (id == null) return null;
    return SecureStorage().getWorkspaceToken(id);
  }

  @override
  Future<List<dynamic>> build(String arg) async {
    datasetKey = arg;
    apiService = ref.watch(apiServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _mounted = false;
      _stopPolling();
      _stopStreaming();
      WidgetsBinding.instance.removeObserver(this);
    });

    final records = await apiService.fetchDatasetRecords(
      datasetId,
      workspaceToken: await _workspaceToken(),
    );
    _startStreaming();
    _startPolling();
    return records;
  }

  Future<void> _initialFetch() async {
    try {
      final records = await apiService.fetchDatasetRecords(
        datasetId,
        workspaceToken: await _workspaceToken(),
      );
      if (_mounted) {
        state = AsyncValue.data(records);
        _startPolling();
      }
    } catch (e, stack) {
      if (_mounted) {
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

  Future<void> _startStreaming() async {
    if (_isStreaming) return;
    _isStreaming = true;

    try {
      final stream = await apiService.streamDatasetRecordEvents(
        datasetId,
        workspaceToken: await _workspaceToken(),
      );
      _eventSubscription = stream.listen(
        (_) => _scheduleStreamRefresh(),
        onError: (error) {
          developer.log('Dataset event stream failed for $datasetId: $error');
          _stopStreaming();
        },
        onDone: _stopStreaming,
        cancelOnError: true,
      );
    } catch (e) {
      developer.log('Unable to start dataset event stream for $datasetId: $e');
      _stopStreaming();
    }
  }

  void _scheduleStreamRefresh() {
    _streamRefreshDebounce?.cancel();
    _streamRefreshDebounce = Timer(
      const Duration(milliseconds: 350),
      _silentFetch,
    );
  }

  void _stopStreaming() {
    _isStreaming = false;
    _streamRefreshDebounce?.cancel();
    _streamRefreshDebounce = null;
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  Future<void> _silentFetch() async {
    if (!_mounted) return;
    try {
      final records = await apiService.fetchDatasetRecords(
        datasetId,
        workspaceToken: await _workspaceToken(),
      );
      if (_mounted) {
        // Only update state; no loading spinner
        state = AsyncValue.data(records);
      }
    } catch (e) {
      developer.log('Silent fetch failed for dataset $datasetId: $e');
      // Do not transition to error state if we already have data, just skip this tick
      if (!state.hasValue && _mounted) {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentFetch(); // Immediately fetch on resume
      _startStreaming();
      _startPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopStreaming();
      _stopPolling();
    }
  }
}
