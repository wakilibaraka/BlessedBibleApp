import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

    // Compute past 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create list of dates (most recent first)
    final dates = List.generate(7, (index) => today.subtract(Duration(days: index)));
    
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
                  
                  String displayDate;
                  if (index == 0) {
                    displayDate = 'Today';
                  } else if (index == 1) {
                    displayDate = 'Yesterday';
                  } else if (index == 2) {
                    displayDate = '2 days ago';
                  } else {
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    displayDate = '${months[date.month - 1]} ${date.day}, ${date.year}';
                  }

                  final bookName = reference.split(' ').first;
                  final bookTag = bookName.toUpperCase();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isToday ? [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: TexturedGlassContainer(
                        borderRadius: BorderRadius.circular(20),
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              ref.read(votdTrackerProvider.notifier).markViewed(date);
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => VerseDetailScreen(reference: reference),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: isToday ? Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 1) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        displayDate,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: isToday ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          bookTag,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    reference,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
