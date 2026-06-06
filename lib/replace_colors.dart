import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int replaced = 0;
  for (final file in files) {
    if (file.path.contains('app_theme.dart')) continue; // Skip theme file itself

    final content = file.readAsStringSync();
    if (content.contains('context.colors.')) {
      final newContent = content.replaceAll('context.colors.', 'context.colors.');
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
      replaced++;
    }
  }
  print('Total files updated: $replaced');
}

