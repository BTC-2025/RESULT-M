import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Smart key-value renderer that adapts display based on the field key/type.
class FieldRenderer {
  static Widget renderValue(BuildContext context, String key, dynamic value) {
    if (value == null) return _emptyText(context);

    final strValue = value.toString().trim();
    if (strValue.isEmpty) return _emptyText(context);

    final lowerKey = key.toLowerCase();

    // Pass / Fail Status Pill
    if (_isStatusKey(lowerKey)) {
      return _buildStatusPill(strValue);
    }

    // Grade Display
    if (lowerKey == 'grade' || lowerKey == 'letter_grade' || lowerKey == 'grade_point') {
      return _buildGrade(strValue);
    }

    // Numeric Score with color (marks, score, percentage)
    if (_isScoreKey(lowerKey)) {
      return _buildScore(context, strValue);
    }

    // Date formatting
    if (_isDateKey(lowerKey)) {
      return _buildDate(context, strValue);
    }

    // List / Array values
    if (value is List) {
      return _buildList(context, value);
    }

    // URL link
    if (strValue.startsWith('http://') || strValue.startsWith('https://')) {
      return _buildLink(context, strValue);
    }

    // Long text
    if (strValue.length > 100) {
      return _buildLongText(context, strValue);
    }

    // Default: just a text
    return Text(
      strValue,
      style: TextStyle(
        color: context.colors.ink,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  static bool _isStatusKey(String k) =>
      k.contains('status') ||
      k.contains('result') ||
      k == 'pass' ||
      k == 'fail' ||
      k.contains('outcome') ||
      k.contains('verdict') ||
      k.contains('selection');

  static bool _isScoreKey(String k) =>
      k.contains('mark') ||
      k.contains('score') ||
      k.contains('percent') ||
      k.contains('cgpa') ||
      k.contains('sgpa') ||
      k.contains('gpa') ||
      k == 'total' ||
      k.contains('rank');

  static bool _isDateKey(String k) =>
      k.contains('date') ||
      k.contains('time') ||
      k == 'dob' ||
      k.contains('published') ||
      k.contains('created');

  static Widget _emptyText(BuildContext context) => Text(
        '—',
        style: TextStyle(color: context.colors.inkFaint, fontSize: 14),
      );

  static Widget _buildStatusPill(String value) {
    final upper = value.toUpperCase();
    Color bg;
    Color text;

    if (['PASS', 'SELECTED', 'QUALIFIED', 'MERIT', 'CLEARED', 'DECLARED',
         'WON', 'WINNER', 'APPROVED'].any((s) => upper.contains(s))) {
      bg = const Color(0xFF16A34A);
      text = Colors.white;
    } else if (['FAIL', 'REJECTED', 'NOT QUALIFIED', 'DISQUALIFIED',
                'ARRESTED', 'DISMISSED'].any((s) => upper.contains(s))) {
      bg = const Color(0xFFDC2626);
      text = Colors.white;
    } else if (['PENDING', 'WAITLIST', 'PROCESSING', 'COUNTING',
                'UPCOMING', 'LIVE', 'ONGOING'].any((s) => upper.contains(s))) {
      bg = const Color(0xFFF59E0B);
      text = Colors.white;
    } else {
      bg = const Color(0xFF6366F1);
      text = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        upper,
        style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
      ),
    );
  }

  static Widget _buildGrade(String value) {
    Color c;
    switch (value.toUpperCase()) {
      case 'O':
      case 'S':
      case 'A+':
      case 'A':
      case 'DISTINCTION':
        c = const Color(0xFF16A34A);
        break;
      case 'B+':
      case 'B':
      case 'FIRST CLASS':
        c = const Color(0xFF2563EB);
        break;
      case 'C':
      case 'C+':
      case 'SECOND CLASS':
        c = const Color(0xFFD97706);
        break;
      case 'D':
      case 'U':
      case 'F':
      case 'FAIL':
        c = const Color(0xFFDC2626);
        break;
      default:
        c = const Color(0xFF6366F1);
    }
    return Text(
      value,
      style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 16),
    );
  }

  static Widget _buildScore(BuildContext context, String value) {
    return Text(
      value,
      style: TextStyle(
        color: context.colors.blue,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }

  static Widget _buildDate(BuildContext context, String value) {
    // Try to format date string nicely
    try {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final formatted = '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
        return Text(
          formatted,
          style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w600, fontSize: 13),
        );
      }
    } catch (_) {}
    return Text(
      value,
      style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  static Widget _buildList(BuildContext context, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5, height: 5,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: BoxDecoration(
                color: context.colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                item.toString(),
                style: TextStyle(color: context.colors.ink, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  static Widget _buildLink(BuildContext context, String url) {
    return Text(
      url,
      style: TextStyle(
        color: context.colors.blue,
        fontSize: 13,
        decoration: TextDecoration.underline,
        decorationColor: context.colors.blue,
      ),
    );
  }

  static Widget _buildLongText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(color: context.colors.ink, fontSize: 13, height: 1.5),
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Renders a full `Map<String, dynamic>` as a clean key-value list.
/// Skips keys that start with '_' and handles nested maps/lists.
class FullRecordPanel extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color? accentColor;

  const FullRecordPanel({super.key, required this.data, this.accentColor});

  /// Keys that should be hidden from the generic display (they're shown in the header)
  static const _hiddenKeys = {
    'id', '_id', 'record_id', 'recordId',
    'Title', 'ID', 'recordTitle', 'recordKey',
  };

  String _formatKey(String key) {
    // Convert snake_case and camelCase to readable title
    final spaced = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .replaceAll('_', ' ')
        .trim();
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = data.entries
        .where((e) =>
            !_hiddenKeys.contains(e.key) &&
            !e.key.startsWith('_') &&
            e.value != null &&
            e.value.toString().isNotEmpty)
        .toList();

    if (filteredEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Center(
          child: Text(
            'No additional details available.',
            style: TextStyle(color: context.colors.inkMuted, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: filteredEntries.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final isLast = i == filteredEntries.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: context.colors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    _formatKey(e.key),
                    style: TextStyle(
                      color: context.colors.inkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: e.value is Map
                      ? _buildNestedMap(context, e.value as Map)
                      : FieldRenderer.renderValue(context, e.key, e.value),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNestedMap(BuildContext context, Map nested) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nested.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${e.key}: ',
              style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Expanded(child: FieldRenderer.renderValue(context, e.key.toString(), e.value)),
          ],
        ),
      )).toList(),
    );
  }
}

/// A compact 2-column grid of key-value highlights for the result header.
class ResultHighlightsGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<String> keys;
  final Color accentColor;

  const ResultHighlightsGrid({
    super.key,
    required this.data,
    required this.keys,
    required this.accentColor,
  });

  String _formatKey(String key) {
    final spaced = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .replaceAll('_', ' ')
        .trim();
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final availableKeys = keys.where((k) => data.containsKey(k) && data[k] != null).toList();
    if (availableKeys.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: availableKeys.length,
      itemBuilder: (context, i) {
        final key = availableKeys[i];
        final value = data[key];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatKey(key),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  value?.toString() ?? '—',
                  style: TextStyle(
                    color: context.colors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
