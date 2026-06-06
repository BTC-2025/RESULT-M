import 'dart:io';

void main() {
  final logFile = File(r'C:\Users\ELCOT\.gemini\antigravity-ide\brain\74deb495-aacc-4a58-8a38-95eba413a17f\.system_generated\tasks\task-5627.log');
  final lines = logFile.readAsLinesSync();

  final Map<String, List<int>> fixes = {};

  for (final line in lines) {
    if (line.contains('- invalid_constant') || line.contains('- non_constant_list_element')) {
      // e.g., "  error - Invalid constant value - lib\screens\results_hub_screen.dart:109:26 - invalid_constant"
      final parts = line.split(' - ');
      if (parts.length >= 3) {
        final fileAndLine = parts[parts.length - 2].trim(); // lib\screens\results_hub_screen.dart:109:26
        final chunks = fileAndLine.split(':');
        if (chunks.length == 3) {
          final filePath = chunks[0];
          final lineNum = int.tryParse(chunks[1]);
          if (lineNum != null) {
            fixes.putIfAbsent(filePath, () => []).add(lineNum - 1); // 0-indexed
          }
        }
      }
    }
  }

  for (final entry in fixes.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) continue;

    final contentLines = file.readAsLinesSync();
    bool changed = false;

    // To handle multiline, we should look at the exact line and also look upwards up to 5 lines for a 'const' keyword.
    for (final l in entry.value) {
      if (l >= 0 && l < contentLines.length) {
        // Look up to 5 lines up for 'const '
        for (int i = l; i >= 0 && i >= l - 5; i--) {
          if (contentLines[i].contains('const ')) {
             contentLines[i] = contentLines[i].replaceFirst('const ', '');
             changed = true;
             break; // Only remove the closest one
          }
        }
      }
    }

    if (changed) {
      file.writeAsStringSync(contentLines.join('\n'));
      print('Fixed constants in ${entry.key}');
    }
  }
}
