import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DRAFT: This is a placeholder Privacy Policy to be reviewed and completed by the developer before release.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Introduction',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to The Blessed Bible. We are committed to protecting your privacy. This Privacy Policy explains how your information is collected, used, and stored when you use our application.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'Data We Collect',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'The Blessed Bible is designed to be a private, offline-first experience. Any personal data you create, such as:\n\n'
              '• Highlights\n'
              '• Bookmarks\n'
              '• Notes\n'
              '• Reading plans and streaks\n'
              '• App preferences\n\n'
              'Are stored entirely locally on your device.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'Data Storage',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'We do not operate servers or maintain accounts. Your data never leaves your device unless you manually initiate a backup or export.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'Third-Party Services',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              '[List any analytics, crash reporting, or external APIs here if applicable, or explicitly state that none are used.]',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'Contact',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have any questions or concerns about our privacy practices, please contact us at: [Your Contact Email]',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 48), // Padding at bottom
          ],
        ),
      ),
    );
  }
}
