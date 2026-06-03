import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_model.dart';

import '../core/storage/secure_storage.dart';
import 'password_unlock_screen.dart';
import '../providers/live_dataset_notifier.dart';
import 'admin/quick_score_entry_screen.dart';

class LocalWorkspaceScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String workspaceName;
  final ResultDomain? domain;
  final Subcategory? subcategory;

  const LocalWorkspaceScreen({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
    this.domain,
    this.subcategory,
  });

  @override
  ConsumerState<LocalWorkspaceScreen> createState() => _LocalWorkspaceScreenState();
}

class _LocalWorkspaceScreenState extends ConsumerState<LocalWorkspaceScreen> with SingleTickerProviderStateMixin {
  bool _isLoadingAccess = true;
  bool _hasAccess = false;
  final _secureStorage = SecureStorage();
  late AnimationController _pulseController;
  final String _dummyDatasetId = "00000000-0000-0000-0000-000000000000"; // Fallback dataset for mock
  final bool _isEditor = true; // MOCK: Assume current user is an Editor/Admin

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final visibility = widget.domain?.visibility ?? WorkspaceVisibility.public;
    
    if (visibility != WorkspaceVisibility.passwordProtected) {
      if (mounted) setState(() { _isLoadingAccess = false; _hasAccess = true; });
      return;
    }

    final token = await _secureStorage.getWorkspaceToken(widget.workspaceId);
    if (token != null && token.isNotEmpty) {
      if (mounted) setState(() { _isLoadingAccess = false; _hasAccess = true; });
      return;
    }

    if (!mounted) return;

    // Navigate to Unlock Screen
    final unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PasswordUnlockScreen(
          workspaceId: widget.workspaceId,
          workspaceName: widget.workspaceName,
        ),
      ),
    );

    if (unlocked == true) {
      if (mounted) setState(() { _isLoadingAccess = false; _hasAccess = true; });
    } else {
      // User cancelled unlock, go back
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showQuickUpdateBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Record to Update', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFF59E0B)),
                title: const Text('Team Alpha Score', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuickScoreEntryScreen(
                      workspaceId: widget.workspaceId,
                      datasetId: _dummyDatasetId,
                      recordId: "record-alpha-id-001",
                    ),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFF59E0B)),
                title: const Text('Team Beta Score', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuickScoreEntryScreen(
                      workspaceId: widget.workspaceId,
                      datasetId: _dummyDatasetId,
                      recordId: "record-beta-id-002",
                    ),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleName = widget.subcategory?.name ?? 'Workspace Details';
    final visibility = widget.domain?.visibility ?? WorkspaceVisibility.public;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(titleName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasAccess)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(liveDatasetProvider(_dummyDatasetId).notifier).refresh();
              },
            ),
          if (visibility == WorkspaceVisibility.passwordProtected)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Protected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: _isLoadingAccess 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : (_hasAccess ? _buildWorkspaceContent() : const SizedBox.shrink()),
      floatingActionButton: (_hasAccess && _isEditor) 
          ? FloatingActionButton.extended(
              onPressed: _showQuickUpdateBottomSheet,
              backgroundColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.flash_on, color: Colors.amberAccent),
              label: const Text('Quick Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            )
          : null,
    );
  }

  Widget _buildWorkspaceContent() {
    final subName = widget.subcategory?.name ?? 'Workspace Details';
    final subSubtitle = widget.subcategory?.subtitle;
    final liveState = ref.watch(liveDatasetProvider(_dummyDatasetId));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Workspace Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(widget.workspaceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(subName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              if (subSubtitle != null) ...[
                const SizedBox(height: 4),
                Text(subSubtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('LIVE SCOREBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),

        // Animated records area
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: liveState.when(
            data: (records) {
              if (records.isEmpty) {
                // Fallback mock
                return Column(
                  children: [
                    _buildLocalEntry(1, 'Team Alpha', '187/4 (18.2 Ov)', 'Batting'),
                    _buildLocalEntry(2, 'Team Beta', '145/8 (16.0 Ov)', 'Batting Complete'),
                    _buildLocalEntry(3, 'Team Gamma', '91/2 (9.0 Ov)', 'Yet to Bat'),
                  ],
                );
              }
              
              // Map dynamic records
              return Column(
                children: records.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var data = entry.value['data'];
                  return _buildLocalEntry(
                    idx + 1,
                    data?['team'] ?? 'Unknown',
                    data?['score'] ?? '0',
                    data?['status'] ?? 'Live',
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: Color(0xFFF59E0B)))),
            error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(24.0), child: Text('Failed to load: $err', style: const TextStyle(color: Colors.red)))),
          ),
        ),

        const SizedBox(height: 24),
        const Text('MAN OF THE MATCH CANDIDATES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildPlayerCard('Rahul V', '62 runs (34 balls)', Icons.sports_cricket, '★★★★★'),
        _buildPlayerCard('Karthik S', '3 wickets (2.2 ov)', Icons.sports_cricket, '★★★★'),
        _buildPlayerCard('Arjun M', '45 runs + 1 catch', Icons.sports_cricket, '★★★'),
      ],
    );
  }

  Widget _buildLocalEntry(int rank, String team, String score, String status) {
    return Container(
      key: ValueKey('${team}_$score'), // For AnimatedSwitcher diffing
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                Text(status, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(score, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(String name, String stat, IconData icon, String stars) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFF59E0B), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                Text(stat, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(stars, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14)),
        ],
      ),
    );
  }
}
