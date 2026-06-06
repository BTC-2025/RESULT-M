import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vote_box_model.dart';
import '../services/api_service.dart';
import 'dart:io';

class VotingHubState {
  final List<VoteBoxModel> voteBoxes;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final bool hasMore;

  VotingHubState({
    this.voteBoxes = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.hasMore = true,
  });

  VotingHubState copyWith({
    List<VoteBoxModel>? voteBoxes,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    bool? hasMore,
  }) {
    return VotingHubState(
      voteBoxes: voteBoxes ?? this.voteBoxes,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class VotingHubNotifier extends Notifier<VotingHubState> {
  late ApiService _apiService;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  VotingHubState build() {
    _apiService = ref.watch(apiServiceProvider);
    Future.microtask(() => refresh());
    return VotingHubState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    _currentPage = 0;
    try {
      final data = await _apiService.fetchVoteBoxes(
        page: _currentPage,
        size: _pageSize,
      );
      
      final parsed = data.map((e) => VoteBoxModel.fromJson(e)).toList();
      state = state.copyWith(
        voteBoxes: parsed,
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
      final data = await _apiService.fetchVoteBoxes(
        page: _currentPage,
        size: _pageSize,
      );
      
      final parsed = data.map((e) => VoteBoxModel.fromJson(e)).toList();
      state = state.copyWith(
        voteBoxes: [...state.voteBoxes, ...parsed],
        isFetchingMore: false,
        hasMore: parsed.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
      _currentPage--;
    }
  }

  Future<void> castVote(String voteBoxId, String optionId) async {
    final boxIndex = state.voteBoxes.indexWhere((b) => b.id == voteBoxId);
    if (boxIndex == -1) return;

    final oldBox = state.voteBoxes[boxIndex];
    if (oldBox.hasVoted) return; // Prevent double voting locally

    // Optimistic Update
    final newOptions = oldBox.options.map((opt) {
      if (opt.id == optionId) {
        return VoteOptionModel(
          id: opt.id,
          optionText: opt.optionText,
          voteCount: (opt.voteCount ?? 0) + 1,
        );
      }
      return opt;
    }).toList();

    final newBox = oldBox.copyWith(
      hasVoted: true,
      selectedOptionId: optionId,
      totalVotes: oldBox.totalVotes + 1,
      options: newOptions,
    );

    final newVoteBoxes = List<VoteBoxModel>.from(state.voteBoxes);
    newVoteBoxes[boxIndex] = newBox;
    state = state.copyWith(voteBoxes: newVoteBoxes);

    try {
      final fingerprint = await _getDeviceFingerprint();
      await _apiService.castVote(voteBoxId, optionId, fingerprint);
    } catch (e) {
      // Revert
      final revertedBoxes = List<VoteBoxModel>.from(state.voteBoxes);
      revertedBoxes[boxIndex] = oldBox;
      state = state.copyWith(voteBoxes: revertedBoxes);
      throw Exception('Failed to cast vote: $e');
    }
  }

  Future<String> _getDeviceFingerprint() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String rawData = 'unknown_device';
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        rawData = '${androidInfo.id}-${androidInfo.model}-${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        rawData = '${iosInfo.identifierForVendor}-${iosInfo.model}-${iosInfo.systemVersion}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        rawData = '${windowsInfo.deviceId}-${windowsInfo.computerName}';
      }
    } catch (e) {
      rawData = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }

    final bytes = utf8.encode(rawData);
    return md5.convert(bytes).toString();
  }

  void addVoteBoxOptimistic(VoteBoxModel newBox) {
    state = state.copyWith(voteBoxes: [newBox, ...state.voteBoxes]);
  }
}

final votingHubProvider = NotifierProvider<VotingHubNotifier, VotingHubState>(
  VotingHubNotifier.new,
);
