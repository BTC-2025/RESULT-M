import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final constPattern = RegExp(r'const\s+([A-Z][a-zA-Z0-9_]*\()');

  for (final file in files) {
    if (file.path.contains('app_theme.dart')) continue;

    final lines = file.readAsLinesSync();
    bool changed = false;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('context.colors.')) {
        // If the line has context.colors and starts with or contains 'Widget('
        if (lines[i].contains('const ')) {
           lines[i] = lines[i].replaceAll(constPattern, r'$1');
           changed = true;
        }
      }
    }

    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
      print('Fixed const in ${file.path}');
    }
  }
}
