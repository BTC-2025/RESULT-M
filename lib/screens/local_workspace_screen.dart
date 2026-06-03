import 'package:flutter/material.dart';
import '../models/domain_model.dart';

import '../core/storage/secure_storage.dart';
import 'password_unlock_screen.dart';

class LocalWorkspaceScreen extends StatefulWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const LocalWorkspaceScreen({super.key, required this.domain, required this.subcategory});

  @override
  State<LocalWorkspaceScreen> createState() => _LocalWorkspaceScreenState();
}

class _LocalWorkspaceScreenState extends State<LocalWorkspaceScreen> {
  bool _isLoadingAccess = true;
  bool _hasAccess = false;
  final _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (widget.domain.visibility != WorkspaceVisibility.passwordProtected) {
      if (mounted) setState(() { _isLoadingAccess = false; _hasAccess = true; });
      return;
    }

    final token = await _secureStorage.getWorkspaceToken(widget.domain.id);
    if (token != null && token.isNotEmpty) {
      if (mounted) setState(() { _isLoadingAccess = false; _hasAccess = true; });
      return;
    }

    if (!mounted) return;

    // Navigate to Unlock Screen
    final unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PasswordUnlockScreen(
          workspaceId: widget.domain.id,
          workspaceName: widget.domain.name,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.domain.visibility == WorkspaceVisibility.passwordProtected)
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
    );
  }

  Widget _buildWorkspaceContent() {
    final sub = widget.subcategory;
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
                  Text(widget.domain.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(sub.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              if (sub.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(sub.subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Scorecard or Leaderboard
        const Text('LIVE SCOREBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildLocalEntry(1, 'Team Alpha', '187/4 (18.2 Ov)', 'Batting'),
        _buildLocalEntry(2, 'Team Beta', '145/8 (16.0 Ov)', 'Batting Complete'),
        _buildLocalEntry(3, 'Team Gamma', '91/2 (9.0 Ov)', 'Yet to Bat'),
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
