import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/field_renderer.dart';

/// Premium School Result Screen.
/// Dynamically renders any JSONB data from the backend.
/// Shows student header, marks table (if present), and extra fields.
class SchoolResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const SchoolResultScreen({super.key, required this.data, required this.title});

  String get _studentName =>
      data['name'] ?? data['student_name'] ?? data['studentName'] ??
      data['candidateName'] ?? data['Title'] ?? 'Student';

  String get _rollNo =>
      data['roll_no'] ?? data['rollNo'] ?? data['rollNumber'] ??
      data['register_number'] ?? data['registerNumber'] ?? data['ID'] ?? '—';

  String get _dob =>
      data['dob'] ?? data['date_of_birth'] ?? data['dateOfBirth'] ?? '—';

  String get _school =>
      data['school'] ?? data['schoolName'] ?? data['institution'] ??
      data['college'] ?? data['organizationName'] ?? '—';

  String get _examName =>
      data['exam_name'] ?? data['examName'] ?? data['board'] ??
      data['examination'] ?? title;

  String get _resultStatus =>
      data['result'] ?? data['status'] ?? data['outcome'] ?? 'N/A';

  bool get _isPass {
    final s = _resultStatus.toUpperCase();
    return s.contains('PASS') || s.contains('DISTINC') || s.contains('MERIT') || s.contains('CLEAR');
  }

  List<Map<String, dynamic>> get _subjects {
    final raw = data['subjects'] ?? data['subject_list'] ?? data['marks_detail'] ?? data['marksDetail'];
    if (raw is List) {
      return raw.whereType<Map>().map((s) => Map<String, dynamic>.from(s)).toList();
    }
    return [];
  }

  // Dynamic marks computed only if subjects present
  int get _totalMarks {
    if (_subjects.isEmpty) return 0;
    return _subjects.fold(0, (sum, s) {
      final t = s['total'] ?? s['totalMarks'] ?? s['marks'] ?? s['score'] ?? 0;
      return sum + (int.tryParse(t.toString()) ?? 0);
    });
  }

  int get _maxMarks {
    if (_subjects.isEmpty) return 0;
    return _subjects.fold(0, (sum, s) {
      final max = s['max_marks'] ?? s['maxMarks'] ?? s['outOf'] ?? 100;
      return sum + (int.tryParse(max.toString()) ?? 100);
    });
  }

  String get _percentage {
    final raw = data['percentage'] ?? data['percent'];
    if (raw != null) return raw.toString();
    if (_maxMarks > 0) return '${(_totalMarks / _maxMarks * 100).toStringAsFixed(1)}%';
    return '';
  }

  Map<String, dynamic> get _extraData {
    const skip = {
      'name', 'student_name', 'studentName', 'candidateName', 'Title',
      'roll_no', 'rollNo', 'rollNumber', 'register_number', 'registerNumber', 'ID',
      'dob', 'date_of_birth', 'dateOfBirth',
      'school', 'schoolName', 'institution', 'college', 'organizationName',
      'exam_name', 'examName', 'board', 'examination',
      'result', 'status', 'outcome',
      'subjects', 'subject_list', 'marks_detail', 'marksDetail',
      'percentage', 'percent',
      'publishedAt', 'published_at',
    };
    return Map.fromEntries(data.entries.where((e) => !skip.contains(e.key) && e.value != null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.teal,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Official Marksheet',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ─── Main Marksheet Card ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.teal.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      border: Border(bottom: BorderSide(color: context.colors.teal.withValues(alpha: 0.2))),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance, color: context.colors.teal, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _examName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.teal, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text('SECONDARY SCHOOL EXAMINATION',
                          style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  // Student Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(context, 'Candidate Name', _studentName),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Roll Number', _rollNo),
                        if (_dob != '—') ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(context, 'Date of Birth', _dob),
                        ],
                        if (_school != '—') ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(context, 'School', _school),
                        ],
                      ],
                    ),
                  ),

                  // Subjects Table (if present)
                  if (_subjects.isNotEmpty) ...[
                    _buildMarksTable(context),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_totalMarks > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL MARKS', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(
                                  _maxMarks > 0 ? '$_totalMarks / $_maxMarks' : '$_totalMarks',
                                  style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          if (_percentage.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('PERCENTAGE', style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(_percentage, style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Result Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isPass
                          ? context.colors.green.withValues(alpha: 0.1)
                          : context.colors.liveRed.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Text(
                        _resultStatus.toUpperCase(),
                        style: TextStyle(
                          color: _isPass ? context.colors.green : context.colors.liveRed,
                          fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Extra Dynamic Fields ─────────────────────────────────────────
            if (_extraData.isNotEmpty) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Additional Details', style: TextStyle(
                  color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900,
                )),
              ),
              const SizedBox(height: 12),
              FullRecordPanel(data: _extraData),
            ],

            const SizedBox(height: 24),

            // ─── Actions ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download, color: context.colors.ink),
                    label: const Text('Download PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: context.colors.teal),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '$_studentName | $_rollNo | $_resultStatus',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.verified, color: Colors.white),
                    label: const Text('Share Result'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const Text(':  ', style: TextStyle(color: Colors.grey)),
        Expanded(
          flex: 3,
          child: Text(value, style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _buildMarksTable(BuildContext context) {
    // Auto-detect columns
    final cols = _subjects.isEmpty ? <String>[] : [
      if (_subjects.first.containsKey('name') || _subjects.first.containsKey('subjectName')) 
        _subjects.first.containsKey('name') ? 'name' : 'subjectName',
      if (_subjects.first.containsKey('theory') || _subjects.first.containsKey('theoryMarks')) 
        _subjects.first.containsKey('theory') ? 'theory' : 'theoryMarks',
      if (_subjects.first.containsKey('practical') || _subjects.first.containsKey('practicalMarks'))
        _subjects.first.containsKey('practical') ? 'practical' : 'practicalMarks',
      if (_subjects.first.containsKey('total') || _subjects.first.containsKey('totalMarks'))
        _subjects.first.containsKey('total') ? 'total' : 'totalMarks',
      if (_subjects.first.containsKey('grade') || _subjects.first.containsKey('letterGrade'))
        _subjects.first.containsKey('grade') ? 'grade' : 'letterGrade',
    ];

    final displayCols = cols.isNotEmpty ? cols : _subjects.first.keys.take(5).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Header row
          Row(
            children: displayCols.map((col) {
              final isName = col.contains('name') || col.contains('Name');
              return Expanded(
                flex: isName ? 3 : 1,
                child: Text(
                  col.replaceAll('_', ' ').replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim().toUpperCase(),
                  textAlign: isName ? TextAlign.left : TextAlign.center,
                  style: TextStyle(color: context.colors.inkMuted, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ..._subjects.map((s) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              children: displayCols.map((col) {
                final isName = col.contains('name') || col.contains('Name');
                return Expanded(
                  flex: isName ? 3 : 1,
                  child: isName
                    ? Text(s[col]?.toString() ?? '—',
                        style: TextStyle(color: context.colors.ink, fontSize: 12, fontWeight: FontWeight.w700))
                    : Center(child: FieldRenderer.renderValue(context, col, s[col])),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }
}
