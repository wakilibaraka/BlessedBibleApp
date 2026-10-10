import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

/// Privacy policy parsed from assets/legal/privacy_policy.json, the same
/// source that generates the hosted docs/privacy_policy.html.
class PrivacyPolicy {
  final String title;
  final String effectiveDate;
  final String url;
  final List<(String heading, List<String> paragraphs)> sections;

  const PrivacyPolicy({
    required this.title,
    required this.effectiveDate,
    required this.url,
    required this.sections,
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) => PrivacyPolicy(
        title: json['title'] as String,
        effectiveDate: json['effectiveDate'] as String,
        url: json['url'] as String,
        sections: [
          for (final s
              in (json['sections'] as List).cast<Map<String, dynamic>>())
            (
              s['heading'] as String,
              (s['paragraphs'] as List).cast<String>(),
            ),
        ],
      );

  static Future<PrivacyPolicy> load() async =>
      PrivacyPolicy.fromJson(jsonDecode(
              await rootBundle.loadString('assets/legal/privacy_policy.json'))
          as Map<String, dynamic>);
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<PrivacyPolicy> _policy = PrivacyPolicy.load();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: FutureBuilder<PrivacyPolicy>(
        future: _policy,
        builder: (context, snapshot) {
          final policy = snapshot.data;
          if (policy == null) {
            return Center(
              child: snapshot.hasError
                  ? const Text('Could not load the privacy policy.')
                  : const CircularProgressIndicator(),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                policy.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Effective Date: ${policy.effectiveDate}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              for (final (heading, paragraphs) in policy.sections)
                _buildSection(theme, heading, paragraphs.join('\n\n')),
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(policy.url),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('View online'),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
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
