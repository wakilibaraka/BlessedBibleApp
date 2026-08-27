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
            Text(
              'Privacy Policy',
              style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: August 26, 2026',
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            _buildSection(theme, 'Introduction',
                'Welcome to The Blessed Bible. We are committed to protecting your privacy and ensuring your personal information is secure. This Privacy Policy explains how your information is collected, used, and stored when you use our application.'),

            _buildSection(theme, 'Information We Collect',
                'When you use The Blessed Bible, we may collect the following types of information:\n\n'
                '• Account Information: When you sign in using Google or Apple, we receive your basic profile information (such as your name and email address) necessary to create and manage your account.\n'
                '• App Activity: We store your reading progress, bookmarks, highlights, notes, and reading plans to provide a seamless experience across your devices.\n'
                '• Usage & Diagnostics: We may collect anonymized crash reports and performance data to help us improve the app\'s stability and user experience.'),

            _buildSection(theme, 'How We Use Your Information',
                'We use the collected data strictly to operate and improve the app. Specifically, we use it to:\n\n'
                '• Sync your reading progress and personal study notes across your devices.\n'
                '• Provide account management and authentication.\n'
                '• Identify and fix bugs through crash reporting.\n\n'
                'We do not sell your personal data, nor do we share it with third parties for marketing or advertising purposes.'),

            _buildSection(theme, 'Data Storage and Security',
                'Your data is stored securely using Google Firebase, which employs industry-standard encryption both in transit and at rest. We restrict access to personal data to ensure it is only used for the purposes outlined in this policy.'),

            _buildSection(theme, 'Your Rights & Account Deletion',
                'You retain full ownership of your data. You have the right to access, modify, or delete your personal information at any time. You can delete your account and all associated data directly within the app by navigating to your Account settings and selecting "Delete Account." Upon deletion, your personal data and study records are permanently removed from our active databases.'),

            _buildSection(theme, 'Third-Party Services',
                'We utilize third-party services, such as Google Firebase (Authentication, Firestore, and Crashlytics) and Apple (Sign in with Apple), to power our app\'s backend and authentication. These services are governed by their respective privacy policies.'),

            _buildSection(theme, 'Changes to This Policy',
                'We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. We encourage you to review it periodically.'),

            _buildSection(theme, 'Contact Us',
                'If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us at:\n\n'
                'wakilibar@gmail.com'),
                
            const SizedBox(height: 48), // Padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
