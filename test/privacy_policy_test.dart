import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/screens/privacy_policy_screen.dart';

void main() {
  test('policy source parses and keeps the required sections', () {
    final policy = PrivacyPolicy.fromJson(
        jsonDecode(File('assets/legal/privacy_policy.json').readAsStringSync())
            as Map<String, dynamic>);
    final headings = policy.sections.map((s) => s.$1).toList();
    expect(
        headings,
        containsAll(<String>[
          'Crash reports',
          'Deleting your account',
          'Who we share data with',
          'Contact',
        ]));
    expect(policy.url, startsWith('https://'));
  });

  testWidgets('privacy policy screen renders from the bundled source',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Summary'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('View online'), 300);
    expect(find.text('View online'), findsOneWidget);
  });
}
