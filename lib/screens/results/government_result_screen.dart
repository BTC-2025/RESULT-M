import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/field_renderer.dart';

/// Government / Civil Services Result Screen — fully dynamic.
class GovernmentResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const GovernmentResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF1B5E3A);

  String get _candidateName =>
      data['candidate_name'] ?? data['candidateName'] ?? data['name'] ??
      data['Title'] ?? 'Candidate';

  String get _regNo =>
      data['register_number'] ?? data['registerNumber'] ?? data['rollNumber'] ??
      data['application_no'] ?? data['applicationNo'] ?? data['ID'] ?? '—';

  String get _department =>
      data['department'] ?? data['agency'] ?? data['organization'] ?? data['exam_body'] ?? '';

  String get _examName =>
      data['exam_name'] ?? data['examName'] ?? data['title'] ?? data['exam'] ?? title;

  String get _status =>
      data['status'] ?? data['selection_status'] ?? data['selectionStatus'] ?? 'N/A';

  String get _rank =>
      data['rank'] ?? data['merit_rank'] ?? data['meritRank'] ?? data['all_india_rank'] ?? '';

  String get _postAllotted =>
      data['post_allotted'] ?? data['postAllotted'] ?? data['designation'] ?? data['post'] ?? '';

  String get _totalScore =>
      data['total_score'] ?? data['totalScore'] ?? data['marks'] ?? data['score'] ?? '';

  Map<String, dynamic> get _highlights {
    return {
      if (_rank.isNotEmpty) 'Merit Rank': _rank,
      if (_totalScore.isNotEmpty) 'Total Score': _totalScore,
      if (_postAllotted.isNotEmpty) 'Post Allotted': _postAllotted,
      if (data['category'] != null) 'Category': data['category'],
      if (data['cutOff'] != null || data['cut_off'] != null) 'Cut-Off': data['cutOff'] ?? data['cut_off'],
    };
  }

  Map<String, dynamic> get _extraData {
    const skip = {
      'candidate_name', 'candidateName', 'name', 'Title',
      'register_number', 'registerNumber', 'rollNumber', 'application_no', 'applicationNo', 'ID',
      'department', 'agency', 'organization', 'exam_body',
      'exam_name', 'examName', 'title', 'exam',
      'status', 'selection_status', 'selectionStatus',
      'rank', 'merit_rank', 'meritRank', 'all_india_rank',
      'post_allotted', 'postAllotted', 'designation', 'post',
      'total_score', 'totalScore', 'marks', 'score',
      'category', 'cutOff', 'cut_off',
    };
    return Map.fromEntries(data.entries.where((e) => !skip.contains(e.key) && e.value != null));
  }

  bool get _isSelected {
    final s = _status.toUpperCase();
    return s.contains('SELECT') || s.contains('QUALIF') || s.contains('MERIT') ||
           s.contains('PASS') || s.contains('CLEAR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        title: Text(_examName, style: const TextStyle(color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Header Banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B3A2F), Color(0xFF1B5E3A)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_department.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_department.toUpperCase(), style: const TextStyle(
                        color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1,
                      )),
                    ),
                  const SizedBox(height: 14),
                  Text(_candidateName, style: const TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900,
                  )),
                  const SizedBox(height: 4),
                  Text(_regNo, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (_isSelected ? Colors.green : Colors.red).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: (_isSelected ? Colors.green : Colors.red).withValues(alpha: 0.5)),
                    ),
                    child: Text(_status.toUpperCase(), style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    )),
                  ),
                ],
              ),
            ),

            // ─── Highlights Grid ───────────────────────────────────────────────
            if (_highlights.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Key Highlights', style: TextStyle(color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ResultHighlightsGrid(
                      data: Map.fromEntries(_highlights.entries.map((e) => MapEntry(e.key, e.value))),
                      keys: _highlights.keys.toList(),
                      accentColor: _themeColor,
                    ),
                  ],
                ),
              ),

            // ─── Full Details ──────────────────────────────────────────────────
            if (_extraData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Details', style: TextStyle(color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    FullRecordPanel(data: _extraData, accentColor: _themeColor),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
