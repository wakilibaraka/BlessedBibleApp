import 'package:flutter/material.dart';

import '../../services/bible_database_service.dart';

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            // Determinate first-run content install progress (92 MB copy).
            // No events while idle -> keep the spinner only.
            StreamBuilder<double>(
              stream: bibleDbService.installProgress,
              builder: (context, snapshot) {
                final progress = snapshot.data;
                if (progress == null || progress <= 0 || progress >= 1) {
                  return const SizedBox.shrink();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: progress,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preparing offline Bible… ${(progress * 100).round()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
