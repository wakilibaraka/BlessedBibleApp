import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Raw styling values in lib/ui that should come from lib/theme instead.
final _patterns = {
  'hexColor': RegExp(r'Color\(0x'),
  'blackWhite': RegExp(r'Colors\.(black|white)\b'),
  'fontSize': RegExp(r'fontSize: [0-9]'),
  'radius': RegExp(r'circular\([0-9]'),
};

const _baselinePath = 'test/design_tokens_baseline.json';

Map<String, Map<String, int>> _count() {
  final result = <String, Map<String, int>>{};
  final files = Directory('lib/ui')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final text = file.readAsStringSync();
    final counts = <String, int>{};
    _patterns.forEach((name, re) {
      final n = re.allMatches(text).length;
      if (n > 0) counts[name] = n;
    });
    if (counts.isNotEmpty) result[file.path] = counts;
  }
  return result;
}

void main() {
  test('no new hard-coded colours, font sizes or radii in lib/ui', () {
    final now = _count();
    // UPDATE_TOKEN_BASELINE=1 flutter test test/design_tokens_test.dart
    // records the current counts after an intentional change.
    if (Platform.environment['UPDATE_TOKEN_BASELINE'] == '1') {
      File(_baselinePath).writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(now)}\n');
      return;
    }
    final baseline = (jsonDecode(File(_baselinePath).readAsStringSync())
            as Map<String, dynamic>)
        .map((k, v) =>
            MapEntry(k, (v as Map<String, dynamic>).cast<String, int>()));
    final grew = <String>[];
    now.forEach((file, counts) {
      counts.forEach((name, n) {
        final allowed = baseline[file]?[name] ?? 0;
        if (n > allowed) grew.add('$file: $name $allowed -> $n');
      });
    });
    expect(grew, isEmpty,
        reason: 'Use Space/Radii/TypeScale/AppPalette from '
            'lib/theme/design_tokens.dart or theme colours instead.');
  });
}
