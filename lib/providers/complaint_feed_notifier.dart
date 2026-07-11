import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class ComplaintFeedState {
  final List<ComplaintModel> complaints;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final bool hasMore;

  ComplaintFeedState({
    this.complaints = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.hasMore = true,
  });

  ComplaintFeedState copyWith({
    List<ComplaintModel>? complaints,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    bool? hasMore,
  }) {
    return ComplaintFeedState(
      complaints: complaints ?? this.complaints,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error, // Can be null to clear
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ComplaintFeedNotifier extends FamilyNotifier<ComplaintFeedState, String> {
  late ApiService _apiService;
  late String sortType;

  String? _currentCategory;
  String? _currentStatus;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  ComplaintFeedState build(String arg) {
    sortType = arg;
    _apiService = ref.watch(apiServiceProvider);
    Future.microtask(refresh);
    return ComplaintFeedState(isLoading: true);
  }

  void setFilters({String? category, String? status}) {
    _currentCategory = category;
    _currentStatus = status;
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    _currentPage = 0;
    try {
      final data = await _apiService.fetchComplaints(
        sort: sortType,
        category: _currentCategory,
        status: _currentStatus,
        page: _currentPage,
        size: _pageSize,
      );

      final parsed = data.map((e) => ComplaintModel.fromJson(e)).toList();
      state = state.copyWith(
        complaints: parsed,
        isLoading: false,
        hasMore: parsed.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true);
    try {
      _currentPage++;
      final data = await _apiService.fetchComplaints(
        sort: sortType,
        category: _currentCategory,
        status: _currentStatus,
        page: _currentPage,
        size: _pageSize,
      );

      final parsed = data.map((e) => ComplaintModel.fromJson(e)).toList();
      state = state.copyWith(
        complaints: [...state.complaints, ...parsed],
        isFetchingMore: false,
        hasMore: parsed.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
      _currentPage--; // Revert page
    }
  }

  Future<void> castVote(String complaintId, String voteType) async {
    final complaintIndex = state.complaints.indexWhere(
      (c) => c.id == complaintId,
    );
    if (complaintIndex == -1) return;

    final oldComplaint = state.complaints[complaintIndex];
    String? newHasUserVoted;
    int newUpvotes = oldComplaint.upvotes;
    int newDownvotes = oldComplaint.downvotes;

    // Optimistic Logic
    if (oldComplaint.hasUserVoted == voteType) {
      // Toggle off
      newHasUserVoted = null;
      if (voteType == 'UP') newUpvotes--;
      if (voteType == 'DOWN') newDownvotes--;
    } else {
      // New vote or change vote
      if (oldComplaint.hasUserVoted == 'UP') newUpvotes--;
      if (oldComplaint.hasUserVoted == 'DOWN') newDownvotes--;

      newHasUserVoted = voteType;
      if (voteType == 'UP') newUpvotes++;
      if (voteType == 'DOWN') newDownvotes++;
    }

    final newNetScore = newUpvotes - newDownvotes;
    final optimisticComplaint = oldComplaint.copyWith(
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      netScore: newNetScore,
      hasUserVoted: newHasUserVoted,
      clearHasUserVoted: newHasUserVoted == null,
    );

    // Update UI immediately
    final newComplaints = List<ComplaintModel>.from(state.complaints);
    newComplaints[complaintIndex] = optimisticComplaint;
    state = state.copyWith(complaints: newComplaints);

    // Call API
    try {
      await _apiService.castComplaintVote(complaintId, voteType);
    } catch (e) {
      // Revert if API fails
      developer.log('Vote failed, reverting: $e');
      final revertedComplaints = List<ComplaintModel>.from(state.complaints);
      revertedComplaints[complaintIndex] = oldComplaint;
      state = state.copyWith(complaints: revertedComplaints);
    }
  }

  void addComplaintOptimistic(ComplaintModel newComplaint) {
    if (sortType == 'new') {
      state = state.copyWith(complaints: [newComplaint, ...state.complaints]);
    } else {
      refresh(); // If trending or top, better to just refresh
    }
  }
}

// Providers
final complaintFeedProvider =
    NotifierProvider.family<ComplaintFeedNotifier, ComplaintFeedState, String>(
      ComplaintFeedNotifier.new,
    );
