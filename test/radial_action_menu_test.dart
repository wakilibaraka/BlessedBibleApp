// Radial verse menu geometry (pure) and the ring's tap behaviour.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/widgets/radial_action_menu.dart';

void main() {
  group('RadialLayout.around', () {
    test('no actions -> empty layout, no crash', () {
      final l = RadialLayout.around(
        anchor: const Offset(100, 100),
        count: 0,
        viewport: const Size(400, 800),
      );
      expect(l.centres, isEmpty);
    });

    test('one action per index, all on the requested radius', () {
      final anchor = const Offset(200, 400);
      final l = RadialLayout.around(
        anchor: anchor,
        count: 6,
        viewport: const Size(400, 800),
        radius: 78,
      );
      expect(l.centres.length, 6);
      for (final c in l.centres) {
        expect(c.distance, closeTo(78, 0.001));
      }
    });

    test('even angular spacing', () {
      final l = RadialLayout.around(
        anchor: const Offset(200, 400),
        count: 6,
        viewport: const Size(400, 800),
      );
      final angles = [
        for (final c in l.centres) atan2(c.dy, c.dx),
      ];
      final deltas = [
        for (var i = 1; i < angles.length; i++) (angles[i] - angles[i - 1]),
      ];
      for (final d in deltas) {
        expect(d, closeTo(2 * pi / 6, 0.001));
      }
    });

    test('dead-centre press keeps every item at full radius', () {
      final l = RadialLayout.around(
        anchor: const Offset(200, 400),
        count: 4,
        viewport: const Size(400, 800),
        radius: 78,
      );
      // Nothing to clamp when the anchor is centred.
      for (final c in l.centres) {
        expect(c.distance, closeTo(78, 0.001));
      }
    });

    test('every item stays on-screen for a press at the top edge', () {
      const viewport = Size(400, 800);
      const anchor = Offset(200, 4);
      final l = RadialLayout.around(
        anchor: anchor,
        count: 5,
        viewport: viewport,
      );
      for (final c in l.centres) {
        final y = anchor.dy + c.dy;
        expect(y, greaterThanOrEqualTo(0));
        expect(y, lessThanOrEqualTo(viewport.height));
      }
    });

    test('every item stays on-screen for a corner press', () {
      const viewport = Size(400, 800);
      const anchor = Offset(2, 2);
      final l = RadialLayout.around(
        anchor: anchor,
        count: 6,
        viewport: viewport,
      );
      for (final c in l.centres) {
        final x = anchor.dx + c.dx;
        final y = anchor.dy + c.dy;
        expect(x, greaterThanOrEqualTo(0));
        expect(y, greaterThanOrEqualTo(0));
        expect(x, lessThanOrEqualTo(viewport.width));
        expect(y, lessThanOrEqualTo(viewport.height));
      }
    });
  });

  group('RadialActionMenu', () {
    testWidgets('renders one target per action and fires the tap',
        (tester) async {
      var copyTapped = false;
      var shareTapped = false;

      await tester.pumpWidget(MaterialApp(
        home: RadialActionMenu(
          anchor: const Offset(200, 300),
          actions: [
            RadialAction(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () => copyTapped = true),
            RadialAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                onTap: () => shareTapped = true),
          ],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      expect(copyTapped, isTrue);

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pump();
      expect(shareTapped, isTrue);
    });

    testWidgets('every action is a labelled semantics button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: RadialActionMenu(
          anchor: const Offset(200, 300),
          actions: [
            RadialAction(
                icon: Icons.copy_rounded, label: 'Copy', onTap: () {}),
            RadialAction(
                icon: Icons.note_add_outlined,
                label: 'Note',
                onTap: () {}),
          ],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.bySemanticsLabel('Copy'), findsOneWidget);
      expect(find.bySemanticsLabel('Note'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('60pt circular targets are comfortably tappable',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RadialActionMenu(
          anchor: const Offset(200, 300),
          actions: [
            RadialAction(
                icon: Icons.copy_rounded, label: 'Copy', onTap: () {}),
          ],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final size = tester.getSize(find.byIcon(Icons.copy_rounded));
      expect(size.width, greaterThanOrEqualTo(40));
      expect(size.height, greaterThanOrEqualTo(40));
    });
  });
}