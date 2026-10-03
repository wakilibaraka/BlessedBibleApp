import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/devotional_provider.dart';
import '../../state/study_layout_provider.dart' show CardSize;
import '../../theme/app_colors.dart';
import '../screens/bible_stories_screen.dart';
import 'textured_glass_container.dart';

/// "Bible Stories" banner card for the Study tab layout grid.
class BibleStoriesBanner extends ConsumerWidget {
  final CardSize size;
  const BibleStoriesBanner({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readCount = ref.watch(devotionalReadProvider).length;
    final favCount = ref.watch(devotionalFavoritesProvider).length;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: RepaintBoundary(
        child: TexturedGlassContainer(
          isScrollable: true,
          borderRadius: BorderRadius.circular(28),
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  AppColors.goldAccent.withValues(alpha: 0.12),
                  Colors.transparent,
                  theme.primaryColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => const BibleStoriesScreen(),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_stories_rounded,
                              size: 20, color: AppColors.goldAccent),
                          const SizedBox(width: 8),
                          Text(
                            'BIBLE STORIES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.goldAccent,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (readCount > 0)
                            Text(
                              '$readCount read',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'An Illustrated Journey Through Scripture',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '500 stories from Genesis to Revelation, each with classical '
                        'Doré engravings, the full KJV passage, and a narrative retelling.'
                        '${favCount > 0 ? ' You have $favCount favorites.' : ''}',
                        maxLines: size == CardSize.small ? 2 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      if (size != CardSize.small) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _previewPill(context, 'Genesis'),
                            const SizedBox(width: 8),
                            _previewPill(context, 'The Gospels'),
                            const SizedBox(width: 8),
                            _previewPill(context, 'Revelation'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewPill(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
