import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
import 'glass_container.dart';

class AppErrorFallback extends StatelessWidget {
  final FlutterErrorDetails? details;

  const AppErrorFallback({super.key, this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: GlassContainer(
              padding: const EdgeInsets.all(32.0),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Something Went Wrong',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'An unexpected issue occurred. Tap below to return to the home screen.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          try {
                            ref.read(navProvider.notifier).setIndex(0);
                          } catch (_) {}
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.home_rounded, size: 20),
                        label: const Text(
                          'Back to Home',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
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
