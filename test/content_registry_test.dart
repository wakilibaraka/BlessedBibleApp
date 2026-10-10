// Download-registry integrity: every translation not on device must be
// fetchable through exactly one working path (offline restore, a
// hash-verified prebuilt pack, or the Free Use Bible API) with complete
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
      expect(size is num && size > 0, isTrue, reason: '$id missing sizeMB');
      final source = t['source'] as String?;
      if (source == 'bundled') {
        // Offline restore: must be a shipped bundled pack.
        expect(TranslationPackStore.bundledPackIds.contains(id), isTrue,
            reason: '$id marked bundled but not shipped in assets/packs');
      } else if (source == 'prebuilt') {
        final url = t['url'] as String?;
        final sha = t['sha256'] as String?;
        expect(url != null && url.startsWith('https://'), isTrue,
            reason: '$id has no valid url');
        expect(sha != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(sha), isTrue,
            reason: '$id has no valid sha256');
      } else {
        expect(source, 'helloao', reason: '$id has unknown source $source');
        expect(
            t['url'], 'https://bible.helloao.org/api/${t['id']}/complete.json',
            reason: '$id has a malformed download url');
      }
      expect(TranslationPackStore.retiredPackIds.contains(id), isFalse,
          reason: 'retired pack $id is still offered');
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
