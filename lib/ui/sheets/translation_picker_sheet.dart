import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/translation_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../data/models/translation_model.dart';
import '../../services/translation_downloader.dart';
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
                      'Bible Translation',
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
                title: 'Reading Layout',
                subtitle: () {
                  switch (readingLayout) {
                    case ReadingLayout.single:
                      return 'One translation';
                    case ReadingLayout.interleaved:
                      return 'Two translations stacked per verse';
                    case ReadingLayout.sideBySide:
                      return 'Two translations in side-by-side columns';
                    case ReadingLayout.chips:
                      return 'Tap a verse to switch its translation';
                  }
                }(),
                selectedValue: readingLayout,
                options: const [
                  MapEntry(ReadingLayout.single, 'Single'),
                  MapEntry(ReadingLayout.interleaved, 'Bilingual'),
                  MapEntry(ReadingLayout.sideBySide, 'Parallel'),
                  MapEntry(ReadingLayout.chips, 'Chips'),
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
                          'Primary',
                          !_isSelectingSecondary,
                          () => setState(() => _isSelectingSecondary = false),
                          theme,
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          'Secondary',
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
                        context, ref, theme, activeTranslationId, installed),
                    loading: () => const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator())),
                    error: (e, st) =>
                        Center(child: Text('Error loading translations: $e')),
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

  Widget _buildTranslationList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String? activeTranslationId,
    List<TranslationInfo> installed,
  ) {
    // Combine installed and downloadable
    final allTranslations = <String,
        List<dynamic>>{}; // map of langName -> list of (TranslationInfo OR Map)

    // 1. Beta Feature Flag: Set to true to re-enable downloadable translations
    bool kEnableDownloads = false;

    // First add installed (they are guaranteed local because they are in the DB)
    for (final t in installed) {
      final lang = t.languageName;
      allTranslations[lang] = allTranslations[lang] ?? [];
      allTranslations[lang]!.add(t);
    }

    // Then add downloadable (if not installed)
    // ignore: dead_code
    if (kEnableDownloads) {
      final installedIds = installed.map((t) => t.translationId).toSet();
      for (final t in TranslationDownloader.downloadableTranslations) {
        final tid = t['db_id'] ?? t['id'];
        if (!installedIds.contains(tid)) {
          final lang = t['langName'] as String;
          allTranslations[lang] = allTranslations[lang] ?? [];
          allTranslations[lang]!.add(t);
        }
      }
    }

    final sortedKeys = allTranslations.keys.toList()
      ..sort((a, b) {
        int pA = _getLanguagePriority(a);
        int pB = _getLanguagePriority(b);
        if (pA != pB) return pA.compareTo(pB);
        return a.compareTo(b); // Alphabetical fallback
      });

    final children = <Widget>[];

    for (final lang in sortedKeys) {
      final list = allTranslations[lang]!;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
          child: Text(
            lang,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );

      for (final item in list) {
        if (item is TranslationInfo) {
          // Installed
          final isSelected = item.translationId == activeTranslationId;
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
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
                              if (item.license.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.license,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.primaryColor,
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
          );
        } else {
          // Downloadable
          children.add(_DownloadableTile(
              item: item as Map<String, dynamic>,
              isSecondary: _isSelectingSecondary));
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

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0.0;
    });

    final tid = widget.item['db_id'] ?? widget.item['id'];
    try {
      await TranslationDownloader.downloadAndInstall(tid, (p) {
        if (mounted) {
          setState(() {
            _progress = p;
          });
        }
      });
      if (mounted) {
        // Refresh the list of available translations
        ref.invalidate(availableTranslationsProvider);

        // Auto-select after download
        if (widget.isSecondary) {
          ref.read(secondaryTranslationProvider.notifier).setTranslation(tid);
        } else {
          ref.read(activeTranslationProvider.notifier).setTranslation(tid);
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = 'Download failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
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
                      Text(
                        "${widget.item['license']} · ${sizeMB.toStringAsFixed(1)} MB",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
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
                    Icons.cloud_download_outlined,
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
