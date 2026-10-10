// Guards the "app opens with no content" class of bugs at test time:
// bundled databases must be real SQLite files (not Git LFS pointers),
// commentary must parse, and the compiled-in fallbacks must be populated.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/content_fallbacks.dart';
import 'package:the_blessed_bible/services/content_asset_guard.dart';
import 'package:the_blessed_bible/utils/isolate_parsers.dart';

void main() {
  group('bundled databases', () {
    final files = <File>[
      File('assets/bible/bible.db'),
      ...Directory('assets/packs')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.db')),
    ];

    for (final f in files) {
      test('${f.path} is a real SQLite database', () {
        expect(f.existsSync(), isTrue, reason: '${f.path} missing');
        final bytes = f.readAsBytesSync();
        expect(
          () => assertBundledSqlite(f.path, bytes),
          returnsNormally,
          reason: 'Run `git lfs install && git lfs pull`',
        );
      });
    }
  });

  // Poetry-dropping regression guard (see tool/repair_pack_poetry.py).
  // A few empty verses are legitimate textual variants (e.g. Luke 17:36);
  // hundreds mean the build pipeline lost content.
  group('no blank verses in shipped text', () {
    final dbs = <String>[
      'assets/bible/bible.db',
      ...Directory('assets/packs')
          .listSync()
          .whereType<File>()
          .map((f) => f.path)
          .where((p) => p.endsWith('.db')),
    ];
    for (final path in dbs) {
      test(path, () async {
        final result = await Process.run('sqlite3', [
          path,
          "SELECT count(*) FROM verses WHERE text IS NULL OR trim(text) = '';",
        ]);
        if (result.exitCode != 0) {
          markTestSkipped('sqlite3 CLI not available');
          return;
        }
        final empty = int.parse((result.stdout as String).trim());
        expect(empty, lessThanOrEqualTo(20),
            reason: '$path has $empty empty verses. '
                'Run: python3 tool/repair_pack_poetry.py $path');
      });
    }
  });

  test('guard rejects a Git LFS pointer with an actionable message', () {
    final pointer = Uint8List.fromList(utf8.encode(
        'version https://git-lfs.github.com/spec/v1\n'
        'oid sha256:0000\nsize 49971200\n'));
    expect(
      () => assertBundledSqlite('assets/bible/bible.db', pointer),
      throwsA(isA<ContentAssetException>().having(
          (e) => e.message, 'message', contains('git lfs pull'))),
    );
  });

  test('commentary.json parses into a non-empty library', () {
    final json = File('assets/commentary/commentary.json').readAsStringSync();
    final entries = parseCommentaryJson(json);
    expect(entries.length, greaterThan(1000));
    expect(entries.where((e) => e.text.trim().isEmpty), isEmpty);
  });

  test('compiled-in fallbacks are populated with real text', () {
    expect(kFallbackVotdPool, isNotEmpty);
    for (final v in kFallbackVotdPool) {
      expect(v.text.trim(), isNotEmpty);
      expect(v.commentarySnippet?.trim(), isNotEmpty);
    }
    expect(kFallbackWotdPool, isNotEmpty);
    for (final w in kFallbackWotdPool) {
      expect(w.word.trim(), isNotEmpty);
      expect(w.snippet.trim(), isNotEmpty);
    }
  });
}
