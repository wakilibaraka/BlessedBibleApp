import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/bible_database_service.dart';
import '../../services/translation_downloader.dart';
import '../../services/translation_pack_store.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';

/// Storage manager: cache, downloaded data, and translation packs.
///
/// Design note: "cache" and "downloads" are deliberately separate
/// sections so the user can clear either, or both — nothing here can
/// touch the core KJV/BBE database, and every destructive row confirms
/// first and reports the bytes actually freed.
class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  /// cache bytes, downloads bytes, per-pack sizes.
  int _cacheBytes = 0;
  int _contentBytes = 0;
  int _downloadBytes = 0;
  bool _busy = false;
  List<_PackRow> _packs = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cache = await _cacheBytesUsed();
    final content = await bibleDbService.contentBytesUsed();
    final packs = await _readPacks();
    final downloads =
        packs.fold<int>(0, (sum, p) => sum + (p.downloaded ? p.sizeBytes : 0));
    if (!mounted) return;
    setState(() {
      _cacheBytes = cache;
      _contentBytes = content;
      _packs = packs;
      _downloadBytes = downloads;
      _loaded = true;
    });
  }

  /// Cache = temp dir (generated share cards, thumbnails) + any
  /// sqlite sidecar files, never the content packs.
  Future<int> _cacheBytesUsed() async {
    var total = 0;
    try {
      final dir = await getTemporaryDirectory();
      if (await dir.exists()) {
        await for (final e in dir.list(recursive: true)) {
          if (e is File) {
            try {
              total += await e.length();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    return total;
  }

  Future<List<_PackRow>> _readPacks() async {
    final rows = <_PackRow>[];
    try {
      final installed = await TranslationPackStore().installedPacks();
      final dir = await _packsDirPath();
      for (final meta in installed) {
        if (TranslationPackStore.isCoreId(meta.id)) continue;
        var size = 0;
        try {
          final f = File('$dir/${meta.id}.db');
          if (await f.exists()) size = await f.length();
        } catch (_) {}
        rows.add(_PackRow(
          id: meta.id,
          name: meta.translationName,
          abbr: meta.abbreviation,
          sizeBytes: size,
          bundled: TranslationPackStore.bundledPackIds.contains(meta.id),
          downloaded: meta.source == 'downloaded',
        ));
      }
      // Installable (not yet on device) packs from the download catalog.
      for (final t in TranslationDownloader.downloadableTranslations) {
        final id = (t['db_id'] ?? t['id']) as String;
        if (rows.any((r) => r.id == id)) continue;
        rows.add(_PackRow(
          id: id,
          name: (t['name'] as String?) ?? id,
          abbr: (t['abbr'] as String?) ?? id.toUpperCase(),
          sizeBytes:
              (((t['sizeMB'] as num?)?.toDouble() ?? 0) * 1024 * 1024).round(),
          bundled: false,
          downloaded: false,
        ));
      }
      rows.sort((a, b) {
        if (a.downloaded != b.downloaded) return a.downloaded ? -1 : 1;
        return b.sizeBytes.compareTo(a.sizeBytes);
      });
    } catch (_) {}
    return rows;
  }

  Future<String> _packsDirPath() async {
    // Mirrors TranslationPackStore's layout.
    final dir = Directory(
        '${(await getApplicationSupportDirectory()).path}/translations');
    return dir.path;
  }

  Future<void> _clearCache() async {
    final confirmed = await _confirm(
      title: 'Clear cache?',
      body: 'Removes temporary files (generated share cards, thumbnails). '
          'Your notes, bookmarks, highlights and downloads are untouched.',
      confirmLabel: 'Clear cache',
    );
    if (!confirmed) return;
    await _run(() async {
      var freed = 0;
      final dir = await getTemporaryDirectory();
      if (await dir.exists()) {
        await for (final e in dir.list(recursive: true)) {
          if (e is File) {
            try {
              final len = await e.length();
              await e.delete();
              freed += len;
            } catch (_) {}
          }
        }
      }
      return freed;
    }, success: 'Cache cleared');
  }

  Future<void> _deletePack(_PackRow pack) async {
    final confirmed = await _confirm(
      title: 'Delete ${pack.name}?',
      body: pack.bundled
          ? 'Frees ${_mb(pack.sizeBytes)}. You can restore it offline from the app at any time.'
          : 'Frees ${_mb(pack.sizeBytes)}. You can download it again later.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await _run(() async {
      final before = pack.sizeBytes;
      await TranslationPackStore().deletePack(pack.id);
      return before;
    }, success: '${pack.abbr} deleted');
  }

  Future<void> _download(_PackRow pack) async {
    await _run(() async {
      await TranslationDownloader.downloadAndInstall(pack.id, (_) {});
      return pack.sizeBytes;
    }, success: '${pack.abbr} downloaded');
  }

  /// Runs a destructive/IO op with a busy flag, honest errors, and a
  /// bytes-freed report. Never silently "succeeds".
  Future<void> _run(
    Future<int> Function() action, {
    required String success,
  }) async {
    if (_busy) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _busy = true);
    int freed = 0;
    String? error;
    try {
      freed = await action();
    } catch (e) {
      error = '$e';
    }
    await _refresh();
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        error != null
            ? 'Could not finish: $error'
            : '$success · freed ${_mb(freed)}',
      ),
    ));
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: destructive
                  ? TextStyle(color: Theme.of(ctx).colorScheme.error)
                  : null,
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String _mb(int bytes) =>
      bytes <= 0 ? '0 MB' : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const SharedAppBar(title: Text('Storage')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                children: [
                  if (!_loaded)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  // ── Summary ────────────────────────────────
                  V2Card(
                    featured: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const V2Eyebrow('On this device'),
                        const SizedBox(height: 10),
                        _StatRow(
                          label: 'Bible content (always kept)',
                          value: _mb(_contentBytes),
                        ),
                        _StatRow(
                            label: 'Downloaded packs',
                            value: _mb(_downloadBytes)),
                        _StatRow(label: 'Cache', value: _mb(_cacheBytes)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Cache ───────────────────────────────────
                  V2Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const V2Eyebrow('Cache'),
                        const SizedBox(height: 6),
                        Text(
                          'Temporary files only — generated share cards and '
                          'thumbnails. Safe to clear at any time.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _clearCache,
                            icon: const Icon(Icons.cleaning_services_rounded),
                            label: const Text('Clear cache'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Downloads / packs ───────────────────────
                  const V2Eyebrow('Translations & downloads'),
                  const SizedBox(height: 8),
                  for (final pack in _packs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: V2Card(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pack.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${pack.abbr} · '
                                    '${_mb(pack.sizeBytes)}'
                                    '${pack.bundled ? " · bundled" : ""}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _PackAction(
                              pack: pack,
                              busy: _busy,
                              onDownload: () => _download(pack),
                              onDelete: () => _deletePack(pack),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Core KJV and BBE are part of the app and can\'t be removed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A translatable pack row (installed or installable).
class _PackRow {
  final String id;
  final String name;
  final String abbr;
  final int sizeBytes;
  final bool bundled;
  final bool downloaded;

  const _PackRow({
    required this.id,
    required this.name,
    required this.abbr,
    required this.sizeBytes,
    required this.bundled,
    required this.downloaded,
  });
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.75))),
          ),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PackAction extends StatelessWidget {
  final _PackRow pack;
  final bool busy;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _PackAction({
    required this.pack,
    required this.busy,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!pack.downloaded) {
      return TextButton.icon(
        onPressed: busy ? null : onDownload,
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text('Get'),
      );
    }
    return IconButton(
      tooltip: 'Delete ${pack.name}',
      onPressed: busy ? null : onDelete,
      icon: const Icon(Icons.delete_outline_rounded),
    );
  }
}
