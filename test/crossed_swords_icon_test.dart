// Crossed swords: the Settings-tab way-out button. Painted (no asset),
// theme-colored, animates once and holds still.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/widgets/crossed_swords_icon.dart';

Widget host({Color? primary, Widget? child}) => MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(
        seedColor: primary ?? Colors.teal,
        brightness: Brightness.dark,
      )),
      home: Scaffold(body: Center(child: child ?? const CrossedSwordsIcon())),
    );

void main() {
  testWidgets('renders and settles without exception', (tester) async {
    await tester.pumpWidget(host());
    expect(find.byType(CrossedSwordsIcon), findsOneWidget);
    // Entrance animation: mid-flight, then at rest.
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(kSwordsDuration);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holds still once the entrance finishes (no loop)',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(kSwordsDuration);
    final a = tester.widget<CustomPaint>(
        find.descendant(
            of: find.byType(CrossedSwordsIcon), matching: find.byType(CustomPaint)));
    await tester.pump(const Duration(seconds: 2));
    final b = tester.widget<CustomPaint>(
        find.descendant(
            of: find.byType(CrossedSwordsIcon), matching: find.byType(CustomPaint)));
    expect(
        (a.painter! as dynamic).progress, (b.painter! as dynamic).progress);
  });

  testWidgets('inherits the theme primary color', (tester) async {
    const seed = Colors.deepPurple;
    await tester.pumpWidget(host(primary: seed));
    await tester.pump(kSwordsDuration);
    final paint = tester.widget<CustomPaint>(
        find.descendant(
            of: find.byType(CrossedSwordsIcon), matching: find.byType(CustomPaint)));
    final painterColor = (paint.painter! as dynamic).color as Color;
    // The painter falls back to Theme.of(context).primaryColor.
    final themePrimary =
        Theme.of(tester.element(find.byType(CrossedSwordsIcon))).primaryColor;
    expect(painterColor, themePrimary);
  });

  testWidgets('explicit color wins over the theme', (tester) async {
    await tester.pumpWidget(host(
      child: const CrossedSwordsIcon(color: Colors.amber),
    ));
    await tester.pump(kSwordsDuration);
    final paint = tester.widget<CustomPaint>(
        find.descendant(
            of: find.byType(CrossedSwordsIcon), matching: find.byType(CustomPaint)));
    expect((paint.painter! as dynamic).color, Colors.amber);
  });

  testWidgets('sized square at the requested size', (tester) async {
    await tester.pumpWidget(host(
      child: const CrossedSwordsIcon(size: 40),
    ));
    await tester.pump(kSwordsDuration);
    final size = tester.getSize(find.byType(CrossedSwordsIcon));
    expect(size, const Size(40, 40));
  });
}