import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/translation_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../data/models/translation_model.dart';
import '../../services/bible_database_service.dart';
import '../../services/translation_downloader.dart';
import '../../services/translation_pack_store.dart';
import '../widgets/animated_segmented_tile.dart';
import '../widgets/textured_glass_container.dart';

class TranslationPickerSheet extends ConsumerStatefulWidget {
  const TranslationPickerSheet({super.key});

  @override
  ConsumerState<TranslationPickerSheet> createState() =>
      _TranslationPickerSheetState();
}

class _TranslationPickerSheetState
    extends ConsumerState<TranslationPickerSheet> {
  bool _isSelectingSecondary = false;

  int _getLanguagePriority(String lang) {
    switch (lang.toLowerCase()) {
      case 'english':
        return 0;
      case 'swahili':
        return 1;
      case 'spanish':
      case 'french':
      case 'german':
      case 'italian':
      case 'romanian':
      case 'portuguese':
      case 'dutch':
      case 'tagalog':
        return 2;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingLayout =
        ref.watch(readSettingsProvider.select((s) => s.readingLayout));

    // Auto-switch to primary if mode changes to single
    if (readingLayout == ReadingLayout.single && _isSelectingSecondary) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isSelectingSecondary = false);
      });
    }

    final activeTranslationId = _isSelectingSecondary
        ? ref.watch(secondaryTranslationProvider)
        : ref.watch(activeTranslationProvider);

    final otherTranslationId = _isSelectingSecondary
        ? ref.watch(activeTranslationProvider)
        : ref.watch(secondaryTranslationProvider);

    final availableTranslations = ref.watch(availableTranslationsProvider);

    return FractionallySizedBox(
      heightFactor: 0.75,
      child: TexturedGlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: EdgeInsets.only(
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.readTranslationTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSegmentedTile<ReadingLayout>(
              title: context.l10n.readLayoutTitle,
              subtitle: () {
                switch (readingLayout) {
                  case ReadingLayout.single:
                    return context.l10n.readLayoutSingleDesc;
                  case ReadingLayout.interleaved:
                    return context.l10n.readLayoutBilingualDesc;
                  case ReadingLayout.sideBySide:
                    return context.l10n.readLayoutParallelDesc;
                  case ReadingLayout.chips:
                    return context.l10n.readLayoutChipsDesc;
                }
              }(),
              selectedValue: readingLayout,
              options: [
                MapEntry(ReadingLayout.single, context.l10n.readLayoutSingle),
                MapEntry(ReadingLayout.interleaved,
                    context.l10n.readLayoutBilingual),
                MapEntry(
                    ReadingLayout.sideBySide, context.l10n.readLayoutParallel),
                MapEntry(ReadingLayout.chips, context.l10n.readLayoutChips),
              ],
              onChanged: (val) {
                HapticFeedback.selectionClick();
                ref.read(readSettingsProvider.notifier).setReadingLayout(val);
              },
            ),
            const SizedBox(height: 16),
            if (readingLayout != ReadingLayout.single) ...[
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        context.l10n.readPrimary,
                        !_isSelectingSecondary,
                        () => setState(() => _isSelectingSecondary = false),
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        context.l10n.readSecondary,
                        _isSelectingSecondary,
                        () => setState(() => _isSelectingSecondary = true),
                        theme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: availableTranslations.when(
                  data: (installed) => _buildTranslationList(
                      context,
                      ref,
                      theme,
                      activeTranslationId,
                      otherTranslationId,
                      installed),
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator())),
                  error: (e, st) => Center(
                      child:
                          Text(context.l10n.readTranslationsLoadError('$e'))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
      String text, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  /// Deletes an installed translation. Backbone translations (KJV + BBE)
  /// live in the core database and cannot be deleted.
  /// Falls back to KJV first so Read never points at a missing translation.
  Future<void> _deleteTranslation(
    BuildContext context,
    WidgetRef ref,
    TranslationInfo item,
  ) async {
    final id = item.translationId;
    if (TranslationPackStore.isCoreId(id)) return;
    if (ref.read(activeTranslationProvider) == id) {
      await ref.read(activeTranslationProvider.notifier).setTranslation('kjv');
    }
    if (ref.read(secondaryTranslationProvider) == id) {
      await ref
          .read(secondaryTranslationProvider.notifier)
          .setTranslation(null);
    }
    try {
      await bibleDbService.deleteTranslationPack(id);
      ref.invalidate(availableTranslationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(context.l10n.readTranslationDeleted(item.translationName)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.readDeleteFailed('$e')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _languageHeader(ThemeData theme, String lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      child: Text(
        lang,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  List<String> _sortedLangs(Iterable<String> langs) {
    final sortedKeys = langs.toList()
      ..sort((a, b) {
        final int pA = _getLanguagePriority(a);
        final int pB = _getLanguagePriority(b);
        if (pA != pB) return pA.compareTo(pB);
        return a.compareTo(b); // Alphabetical fallback
      });
    return sortedKeys;
  }

  Widget _buildTranslationList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String? activeTranslationId,
    String? otherTranslationId,
    List<TranslationInfo> installed,
  ) {
    final installedIds = installed.map((t) => t.translationId).toSet();

    // Not installed: bundled packs the user removed (restore offline) plus
    // network-downloadable translations.
    final pending = TranslationDownloader.downloadableTranslations.where((t) {
      final tid = (t['db_id'] ?? t['id']) as String;
      return !installedIds.contains(tid);
    }).toList();

    final installedByLang = <String, List<TranslationInfo>>{};
    for (final t in installed) {
      installedByLang[t.languageName] = installedByLang[t.languageName] ?? [];
      installedByLang[t.languageName]!.add(t);
    }
    final pendingByLang = <String, List<Map<String, dynamic>>>{};
    for (final t in pending) {
      final lang = t['langName'] as String;
      pendingByLang[lang] = pendingByLang[lang] ?? [];
      pendingByLang[lang]!.add(t);
    }

    final children = <Widget>[];

    for (final lang in _sortedLangs(installedByLang.keys)) {
      children.add(_languageHeader(theme, lang));
      for (final item in installedByLang[lang]!) {
        // Installed
        final isSelected = item.translationId == activeTranslationId;
        final isOtherSelected = ref.read(readSettingsProvider).readingLayout !=
                ReadingLayout.single &&
            item.translationId == otherTranslationId;
        // Backbone (KJV + BBE) lives in the core database and cannot be
        // deleted; everything else can be removed to slim the app.
        final isLocked = TranslationPackStore.isCoreId(item.translationId);
        final isKjv = item.translationId == 'kjv';
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Opacity(
              opacity: isOtherSelected ? 0.4 : 1.0,
              child: Material(
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isOtherSelected
                      ? null
                      : () {
                          if (_isSelectingSecondary) {
                            ref
                                .read(secondaryTranslationProvider.notifier)
                                .setTranslation(item.translationId);
                          } else {
                            ref
                                .read(activeTranslationProvider.notifier)
                                .setTranslation(item.translationId);
                          }
                          Navigator.of(context).pop();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.translationName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              Builder(builder: (_) {
                                final subtitle = isKjv
                                    ? context.l10n.readKjvAlwaysAvailable
                                    : item.license;
                                if (subtitle.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        if (!isLocked)
                          IconButton(
                            tooltip: context.l10n
                                .readDeleteTranslation(item.translationName),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20),
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            onPressed: () =>
                                _deleteTranslation(context, ref, item),
                          ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.primaryColor,
                          )
                        else if (isLocked)
                          Tooltip(
                            message: context.l10n.readCannotDeleteBackbone,
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                          )
                        else
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    if (pendingByLang.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, top: 16.0),
          child: Text(
            context.l10n.readAvailableToAdd,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
      for (final lang in _sortedLangs(pendingByLang.keys)) {
        children.add(_languageHeader(theme, lang));
        for (final item in pendingByLang[lang]!) {
          children.add(_DownloadableTile(
              item: item, isSecondary: _isSelectingSecondary));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _DownloadableTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  final bool isSecondary;
  const _DownloadableTile({required this.item, required this.isSecondary});

  @override
  ConsumerState<_DownloadableTile> createState() => _DownloadableTileState();
}

class _DownloadableTileState extends ConsumerState<_DownloadableTile> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _error;

  bool get _isRestore => widget.item['source'] == 'bundled';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0.0;
    });

    final tid = (widget.item['db_id'] ?? widget.item['id']) as String;
    try {
      if (_isRestore) {
        // Bundled pack the user removed: re-copy from the APK (instant,
        // offline) instead of downloading.
        await bibleDbService.restoreBundledPack(tid);
      } else {
        await TranslationDownloader.downloadAndInstall(tid, (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        });
      }
      if (mounted) {
        // Refresh the list of available translations
        ref.invalidate(availableTranslationsProvider);

        // Auto-select after download
        if (widget.isSecondary) {
          unawaited(ref
              .read(secondaryTranslationProvider.notifier)
              .setTranslation(tid));
        } else {
          unawaited(
              ref.read(activeTranslationProvider.notifier).setTranslation(tid));
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Offline (or otherwise unreachable network) gets a clean message
        // instead of a raw socket exception.
        final text = '$e';
        final offline = text.contains('SocketException') ||
            text.contains('Failed host lookup') ||
            text.contains('Network is unreachable') ||
            text.contains('Connection refused') ||
            text.contains('Connection reset');
        final message = offline
            ? context.l10n.readNoInternet
            : (_isRestore
                ? context.l10n.readRestoreFailedDetail('$e')
                : context.l10n.readDownloadFailedDetail('$e'));
        setState(() {
          _isDownloading = false;
          _error = _isRestore
              ? context.l10n.readRestoreFailed
              : context.l10n.readDownloadFailed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeMB = widget.item['sizeMB'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isDownloading ? null : _startDownload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item['name'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Builder(builder: (_) {
                        final isRestore = widget.item['source'] == 'bundled';
                        final label = isRestore
                            ? "${widget.item['license']} · ${sizeMB.toStringAsFixed(1)} MB · ${context.l10n.readRestoreOffline}"
                            : "${widget.item['license']} · ${sizeMB.toStringAsFixed(1)} MB";
                        return Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        );
                      }),
                      if (_error != null)
                        Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_isDownloading) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _progress,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ]
                    ],
                  ),
                ),
                if (!_isDownloading)
                  Icon(
                    widget.item['source'] == 'bundled'
                        ? Icons.settings_backup_restore_rounded
                        : Icons.cloud_download_outlined,
                    color: theme.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
