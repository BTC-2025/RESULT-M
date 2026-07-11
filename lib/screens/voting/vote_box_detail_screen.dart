import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/vote_box_model.dart';
import '../../services/api_service.dart';
import '../../providers/voting_hub_notifier.dart';
import '../../core/storage/secure_storage.dart';

class VoteBoxDetailScreen extends ConsumerStatefulWidget {
  final String voteBoxId;

  const VoteBoxDetailScreen({super.key, required this.voteBoxId});

  @override
  ConsumerState<VoteBoxDetailScreen> createState() =>
      _VoteBoxDetailScreenState();
}

class _VoteBoxDetailScreenState extends ConsumerState<VoteBoxDetailScreen> {
  VoteBoxModel? _voteBox;
  List<VoteResultsModel>? _results;
  bool _isLoading = true;
  String? _error;

  final _accessCodeController = TextEditingController();
  bool _isLocked = false;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.fetchVoteBoxDetail(widget.voteBoxId);
      final box = VoteBoxModel.fromJson(data);

      List<VoteResultsModel>? results;
      if (box.hasVoted || _isExpired(box)) {
        final resData = await apiService.fetchVoteResults(widget.voteBoxId);
        results = resData.map((e) => VoteResultsModel.fromJson(e)).toList();
      }

      if (mounted) {
        setState(() {
          _voteBox = box;
          _results = results;
          _isLoading = false;
          _isLocked = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('Valid vote box token required')) {
        setState(() {
          _isLocked = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unlock() async {
    final code = _accessCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isUnlocking = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final token = await apiService.unlockVoteBox(widget.voteBoxId, code);
      await SecureStorage().saveVoteBoxToken(widget.voteBoxId, token);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Poll unlocked!')));
      await _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unlock: $e')));
    } finally {
      if (mounted) setState(() => _isUnlocking = false);
    }
  }

  bool _isExpired(VoteBoxModel box) {
    return box.endsAt != null && DateTime.now().isAfter(box.endsAt!);
  }

  Future<void> _castVote(String optionId) async {
    if (_voteBox == null) return;

    try {
      // Show loading indicator or optimistic update
      // We will use the VotingHubNotifier for the API call and fingerprint logic
      await ref
          .read(votingHubProvider.notifier)
          .castVote(widget.voteBoxId, optionId);

      // Re-fetch to get actual results
      await _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vote failed: $e')));
    }
  }

  @override
  void dispose() {
    _accessCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    if (_isLocked) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Password Protected Poll',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the access code to view and vote.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _accessCodeController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Access Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUnlocking ? null : _unlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUnlocking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Unlock',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _voteBox == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final isExpired = _isExpired(_voteBox!);
    final showResults = _voteBox!.hasVoted || isExpired;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Poll',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Check out this poll: https://resulthub.app/votes/${widget.voteBoxId}',
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _voteBox!.visibility,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                if (isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CLOSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _voteBox!.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            if (_voteBox!.description != null &&
                _voteBox!.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _voteBox!.description!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 32),

            if (!showResults) ...[
              const Text(
                'Select an option:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ..._voteBox!.options.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => _castVote(opt.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              opt.optionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (_results != null) ...[
              const Text(
                'Results:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ..._results!.map((res) {
                final isSelected = _voteBox!.selectedOptionId == res.optionId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2563EB),
                                    size: 18,
                                  ),
                                if (isSelected) const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    res.optionText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${res.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${res.voteCount} votes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            height: 12,
                            width:
                                MediaQuery.of(context).size.width *
                                (res.percentage / 100) *
                                0.85, // Math to roughly scale bar width
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_voteBox!.totalVotes} total votes',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
