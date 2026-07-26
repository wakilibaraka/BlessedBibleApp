import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/textured_glass_container.dart';

class ReadingPlanScreen extends ConsumerWidget {
  const ReadingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reading Plans',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP HEADER SECTION ─────────────────────────────
              Text(
                'RESOURCE LIBRARY',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything you need to immerse in the Word.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Structured daily reading plans, topical studies, and chronological guides designed to nourish your daily spiritual journey.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // ── PLAN CARDS ─────────────────────────────────────
              _buildPlanCard(
                context,
                theme,
                tag: 'YEAR ONE • ACTIVE',
                title: 'Chronological Bible in a Year',
                description: 'Read through the Scriptures in the historical order events occurred. Currently on Day 203 of 365.',
                actionText: 'CONTINUE DAY 203',
                iconData: Icons.auto_stories_rounded,
                isActive: true,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                theme,
                tag: 'BIBLE STUDIES',
                title: 'The Gospels & Acts',
                description: 'A 90-day deep dive into the life, teachings, parables, and resurrection of Jesus Christ.',
                actionText: 'START PLAN',
                iconData: Icons.menu_book_rounded,
                isActive: false,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                theme,
                tag: 'PROPHETIC STUDIES',
                title: 'Daniel & Revelation Unlocked',
                description: 'Explore verse-by-verse prophetic insights with historicist commentary and cross-references.',
                actionText: 'EXPLORE STUDY',
                iconData: Icons.explore_rounded,
                isActive: false,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                theme,
                tag: 'WISDOM & POETRY',
                title: 'Psalms & Proverbs Daily',
                description: 'Daily wisdom for peace of mind, prayerful reflection, and practical Christian living.',
                actionText: 'VIEW PLAN',
                iconData: Icons.wb_sunny_rounded,
                isActive: false,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    ThemeData theme, {
    required String tag,
    required String title,
    required String description,
    required String actionText,
    required IconData iconData,
    required bool isActive,
  }) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.primaryColor.withValues(alpha: 0.2)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: isActive ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                actionText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
