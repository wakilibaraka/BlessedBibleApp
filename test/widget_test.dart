// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_blessed_bible/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TheBlessedBibleApp(),
      ),
    );

    // Verify that our app renders.
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for initial animations to start
    await tester.pump(const Duration(seconds: 1));
  });
}
