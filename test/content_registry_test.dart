// Download-registry integrity: every translation not on device must be
// fetchable through exactly one working path (offline restore, verified
// Firebase Storage pack, or reachable helloao endpoint) with complete
// display metadata. Pure unit test — no providers, no platform channels.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/translation_downloader.dart';
import 'package:the_blessed_bible/services/translation_pack_store.dart';

void main() {
  test('download registry is a clean surebet', () {
    final ids = <String>{};
    for (final t in TranslationDownloader.downloadableTranslations) {
      final id = ((t['db_id'] ?? t['id']) as String);
      expect(ids.add(id), isTrue, reason: 'duplicate registry id $id');
      expect((t['langName'] as String?)?.isNotEmpty ?? false, isTrue,
          reason: '$id missing langName');
      expect((t['name'] as String?)?.isNotEmpty ?? false, isTrue,
          reason: '$id missing name');
      expect((t['license'] as String?)?.isNotEmpty ?? false, isTrue,
          reason: '$id missing license');
      final size = t['sizeMB'];
      expect(size is num && size > 0, isTrue,
          reason: '$id missing sizeMB');
      final source = t['source'] as String?;
      if (source == 'bundled') {
        // Offline restore: must be a shipped bundled pack.
        expect(TranslationPackStore.bundledPackIds.contains(id), isTrue,
            reason: '$id marked bundled but not shipped in assets/packs');
      } else if (source == 'storage') {
        final url = t['storageUrl'] as String?;
        final sha = t['sha256'] as String?;
        expect(url != null && url.startsWith('https://'), isTrue,
            reason: '$id has no valid storageUrl');
        expect(
            sha != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(sha), isTrue,
            reason: '$id has no valid sha256');
      } else {
        // helloao JSON flow needs a download id (verified reachable).
        expect(((t['id']) as String?)?.isNotEmpty ?? false, isTrue,
            reason: '$id missing helloao id');
      }
    }
    // Backbone translations live in core: never downloadable, never
    // deletable, always on device.
    for (final core in TranslationPackStore.coreIds) {
      expect(ids.contains(core), isFalse,
          reason: 'backbone $core must not be downloadable');
    }
    // Every deletable bundled pack is restorable through the registry.
    for (final b in TranslationPackStore.bundledPackIds) {
      expect(ids.contains(b), isTrue,
          reason: 'bundled $b not restorable after delete');
    }
  });
}
