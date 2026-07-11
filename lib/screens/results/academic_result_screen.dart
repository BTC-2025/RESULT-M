import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/field_renderer.dart';

/// Premium Academic Result Screen.
/// Renders dynamically from any JSONB record — no hardcoded fields.
/// If the record contains 'subjects' as a List, renders a subject table.
/// Otherwise falls back to FullRecordPanel for arbitrary key-values.
class AcademicResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const AcademicResultScreen({super.key, required this.data, required this.title});

  // ─── Key extraction helpers ───────────────────────────────────────────────

  String get _studentName =>
      data['student_name'] ?? data['studentName'] ?? data['candidateName'] ??
      data['name'] ?? data['Title'] ?? 'Student';

  String get _regNo =>
      data['register_number'] ?? data['registerNumber'] ?? data['rollNumber'] ??
      data['roll_no'] ?? data['roll_number'] ?? data['ID'] ?? data['id'] ?? '—';

  String get _course =>
      data['course'] ?? data['department'] ?? data['program'] ??
      data['courseName'] ?? data['branch'] ?? 'N/A';

  String get _college =>
      data['college'] ?? data['institution'] ?? data['university'] ??
      data['schoolName'] ?? data['organizationName'] ?? 'N/A';

  String get _semester =>
      data['semester'] ?? data['semesterNo'] ?? data['year'] ??
      data['exam_month'] ?? 'N/A';

  String get _resultStatus =>
      data['status'] ?? data['result'] ?? data['resultStatus'] ??
      data['outcome'] ?? 'N/A';

  bool get _isPass {
    final s = _resultStatus.toUpperCase();
    return s.contains('PASS') || s.contains('CLEAR') ||
           s.contains('QUALIF') || s.contains('MERIT');
  }

  String get _cgpa =>
      data['cgpa'] ?? data['overall_gpa'] ?? data['gpa'] ??
      data['grade_point'] ?? data['overallGpa'] ?? '';

  String get _sgpa =>
      data['sgpa'] ?? data['semester_gpa'] ?? data['semesterGpa'] ?? '';

  String get _percentage =>
      data['percentage'] ?? data['percent'] ?? data['overallPercentage'] ?? '';

  String get _totalMarks =>
      data['total_marks'] ?? data['totalMarks'] ?? data['marks_obtained'] ?? '';

  String get _resultClass =>
      data['class'] ?? data['grade_class'] ?? data['classification'] ??
      data['honour'] ?? '';

  List<Map<String, dynamic>> get _subjects {
    final raw = data['subjects'] ?? data['subject_list'] ?? data['marks'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
    }
    return [];
  }

  /// Extra fields to show as highlights (not already shown above)
  Map<String, dynamic> get _extraHighlights {
    const skip = {
      'student_name', 'studentName', 'candidateName', 'name', 'Title',
      'register_number', 'registerNumber', 'rollNumber', 'roll_no', 'roll_number', 'ID', 'id',
      'course', 'department', 'program', 'courseName', 'branch',
      'college', 'institution', 'university', 'schoolName', 'organizationName',
      'semester', 'semesterNo', 'year', 'exam_month',
      'status', 'result', 'resultStatus', 'outcome',
      'cgpa', 'overall_gpa', 'gpa', 'grade_point', 'overallGpa',
      'sgpa', 'semester_gpa', 'semesterGpa',
      'percentage', 'percent', 'overallPercentage',
      'total_marks', 'totalMarks', 'marks_obtained',
      'class', 'grade_class', 'classification', 'honour',
      'subjects', 'subject_list', 'marks',
      'publishedAt', 'published_at', 'createdAt',
    };
    return Map.fromEntries(data.entries.where((e) => !skip.contains(e.key) && e.value != null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2240),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white70),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$_studentName | $_regNo | $_resultStatus'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result info copied!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header Banner ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2240), Color(0xFF1A3A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ACADEMIC RESULT', style: TextStyle(
                          color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2,
                        )),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isPass ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _resultStatus.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _studentName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_regNo, style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w700)),
                  if (_course.isNotEmpty && _course != 'N/A') ...[
                    const SizedBox(height: 4),
                    Text(_course, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ],
              ),
            ),

            // ─── Key Stats ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1A3A5C).withValues(alpha: 0.08),
              child: Row(
                children: [
                  if (_cgpa.isNotEmpty) ...[
                    _StatPill('CGPA', _cgpa, const Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                  ],
                  if (_sgpa.isNotEmpty) ...[
                    _StatPill('SGPA', _sgpa, const Color(0xFF8B5CF6)),
                    const SizedBox(width: 12),
                  ],
                  if (_percentage.isNotEmpty) ...[
                    _StatPill('Percentage', '$_percentage%', const Color(0xFF10B981)),
                    const SizedBox(width: 12),
                  ],
                  if (_resultClass.isNotEmpty)
                    Expanded(child: _StatPill('Class', _resultClass, const Color(0xFFF59E0B))),
                  if ([_cgpa, _sgpa, _percentage, _resultClass].every((s) => s.isEmpty))
                    Text('Result declared', style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Info Grid ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: [
                    if (_college != 'N/A') ...[
                      _infoRow(context, 'Institution', _college),
                      const Divider(height: 20),
                    ],
                    if (_semester != 'N/A') ...[
                      _infoRow(context, 'Semester / Year', _semester),
                      const Divider(height: 20),
                    ],
                    if (_totalMarks.isNotEmpty)
                      _infoRow(context, 'Total Marks', _totalMarks),
                  ],
                ),
              ),
            ),

            // ─── Subjects Table (if subjects key exists) ──────────────────────
            if (_subjects.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Subjects & Grades', style: TextStyle(
                  color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900,
                )),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SubjectsTable(subjects: _subjects, context: context),
              ),
            ],

            // ─── Extra Dynamic Fields ─────────────────────────────────────────
            if (_extraHighlights.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Additional Details', style: TextStyle(
                  color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900,
                )),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FullRecordPanel(data: _extraHighlights, accentColor: const Color(0xFF1A3A5C)),
              ),
            ],

            const SizedBox(height: 24),

            // ─── Actions ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.download_rounded, size: 18, color: context.colors.ink),
                      label: Text('Download', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A3A5C)),
                      onPressed: () {},
                      icon: const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                      label: const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data.entries.map((e) => '${e.key}: ${e.value}').join('\n')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.share_rounded),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext ctx, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(color: ctx.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const Text(':  ', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(value, style: TextStyle(color: ctx.colors.ink, fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SubjectsTable extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final BuildContext context;
  const _SubjectsTable({required this.subjects, required this.context});

  // Detect the columns from the first subject entry
  List<String> get _columns {
    if (subjects.isEmpty) return [];
    // Priority order for well-known keys
    final priority = ['code', 'subjectCode', 'name', 'subjectName', 'credits', 'marks', 'marksObtained', 'grade', 'result'];
    final available = subjects.first.keys.toList();
    final sorted = [
      ...priority.where((k) => available.contains(k)),
      ...available.where((k) => !priority.contains(k)),
    ];
    return sorted.take(6).toList(); // Limit to 6 columns for screen
  }

  String _fmtKey(String k) {
    return k.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
      .replaceAll('_', ' ').trim().toUpperCase();
  }

  @override
  Widget build(BuildContext ctx) {
    final cols = _columns;
    if (cols.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: ctx.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ctx.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: ctx.colors.border, width: 0.8),
          ),
          columnWidths: {
            for (var i = 0; i < cols.length; i++)
              i: cols[i].contains('name') || cols[i].contains('Name')
                  ? const FlexColumnWidth(3)
                  : const FlexColumnWidth(1.5),
          },
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: ctx.colors.surfaceAlt),
              children: cols.map((col) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  _fmtKey(col),
                  style: TextStyle(color: ctx.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              )).toList(),
            ),
            // Data rows
            ...subjects.map((sub) => TableRow(
              children: cols.map((col) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: FieldRenderer.renderValue(ctx, col, sub[col]),
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }
}
