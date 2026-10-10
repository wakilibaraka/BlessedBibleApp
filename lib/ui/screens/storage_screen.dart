import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
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
      title: context.l10n.spaceClearCacheTitle,
      body: context.l10n.spaceClearCacheBody,
      confirmLabel: context.l10n.spaceClearCache,
    );
    if (!confirmed || !mounted) return;
    final success = context.l10n.spaceCacheCleared;
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
    }, success: success);
  }

  Future<void> _deletePack(_PackRow pack) async {
    final confirmed = await _confirm(
      title: context.l10n.spaceDeletePackTitle(pack.name),
      body: pack.bundled
          ? context.l10n.spaceDeletePackBundled(_mb(pack.sizeBytes))
          : context.l10n.spaceDeletePackDownloaded(_mb(pack.sizeBytes)),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final success = context.l10n.spacePackDeleted(pack.abbr);
    await _run(() async {
      final before = pack.sizeBytes;
      await TranslationPackStore().deletePack(pack.id);
      return before;
    }, success: success);
  }

  Future<void> _download(_PackRow pack) async {
    await _run(() async {
      await TranslationDownloader.downloadAndInstall(pack.id, (_) {});
      return pack.sizeBytes;
    }, success: context.l10n.spacePackDownloaded(pack.abbr));
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
            ? context.l10n.spaceCouldNotFinish(error)
            : context.l10n.spaceFreed(success, _mb(freed)),
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
            child: Text(context.l10n.commonCancel),
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
        appBar: SharedAppBar(title: Text(context.l10n.spaceStorageTitle)),
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
                        V2Eyebrow(context.l10n.spaceOnThisDevice),
                        const SizedBox(height: 10),
                        _StatRow(
                          label: context.l10n.spaceBibleContent,
                          value: _mb(_contentBytes),
                        ),
                        _StatRow(
                            label: context.l10n.spaceDownloadedPacks,
                            value: _mb(_downloadBytes)),
                        _StatRow(
                            label: context.l10n.spaceCache,
                            value: _mb(_cacheBytes)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Cache ───────────────────────────────────
                  V2Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        V2Eyebrow(context.l10n.spaceCache),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.spaceCacheExplain,
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
                            label: Text(context.l10n.spaceClearCache),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Downloads / packs ───────────────────────
                  V2Eyebrow(context.l10n.spaceTranslationsDownloads),
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
                                    '${pack.bundled ? context.l10n.spaceBundledSuffix : ""}',
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
                    context.l10n.spaceCoreNotRemovable,
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
        label: Text(context.l10n.spaceGet),
      );
    }
    return IconButton(
      tooltip: context.l10n.spaceDeletePackTooltip(pack.name),
      onPressed: busy ? null : onDelete,
      icon: const Icon(Icons.delete_outline_rounded),
    );
  }
}
