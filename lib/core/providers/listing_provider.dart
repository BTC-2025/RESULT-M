import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class ListingState {
  final List<dynamic> records;
  final bool isLoading;
  final String? error;

  ListingState({this.records = const [], this.isLoading = true, this.error});

  ListingState copyWith({List<dynamic>? records, bool? isLoading, String? error}) {
    return ListingState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ListingNotifier extends StateNotifier<ListingState> {
  final ApiService api;
  final String datasetId;

  ListingNotifier(this.api, this.datasetId) : super(ListingState()) {
    fetchPage();
  }

  Future<void> fetchPage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await api.fetchDatasetRecords(datasetId, query: '', size: 20);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load records');
    }
  }
}

final listingProvider = StateNotifierProvider.family<ListingNotifier, ListingState, String>((ref, datasetId) {
  return ListingNotifier(ref.read(apiServiceProvider), datasetId);
});
