import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/home_provider.dart';
import '../../state/votd_tracker_provider.dart';
import '../widgets/textured_glass_container.dart';
import 'verse_detail_screen.dart';

class VotdArchiveScreen extends ConsumerWidget {
  const VotdArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewedDays = ref.watch(votdTrackerProvider);

    // Compute past 30 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create list of dates (most recent first)
    final dates = List.generate(30, (index) => today.subtract(Duration(days: index)));
    
    // Epoch used for VotD calculation
    final epoch = DateTime(2026, 1, 1);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Daily Verses',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final date = dates[index];
                  final isToday = index == 0;
                  
                  // Compute VotD for this specific date
                  final dayIndex = date.difference(epoch).inDays % HomeNotifier.votdList.length;
                  // Handle negative modulo correctly just in case
                  final validDayIndex = dayIndex < 0 ? dayIndex + HomeNotifier.votdList.length : dayIndex;
                  final votdEntry = HomeNotifier.votdList[validDayIndex];
                  final reference = votdEntry[0];
                  final text = votdEntry[1];
                  
                  // Format date string
                  final String dateString = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  
                  final isViewed = viewedDays.contains(dateString);
                  
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  final displayDate = isToday ? 'Today' : '${months[date.month - 1]} ${date.day}, ${date.year}';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TexturedGlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () {
                          // Mark as viewed manually just in case
                          ref.read(votdTrackerProvider.notifier).markViewed(date);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VerseDetailScreen(reference: reference),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Viewed Indicator
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isViewed 
                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                                      : theme.primaryColor,
                                ),
                              ),
                            ),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        reference,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isViewed 
                                              ? theme.colorScheme.onSurface 
                                              : theme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        displayDate,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: dates.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
