// Study hub: full-width single column, avatar header (no streak),
// account menu rows. Harness mirrors plans_library_test.dart.

import 'package:blessed_account/blessed_account.dart';
import 'package:blessed_account/testing.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/study_screen_v2.dart';
import 'package:the_blessed_bible/ui/widgets/account_menu.dart';
import 'package:the_blessed_bible/ui/widgets/study_v2_widgets.dart';

void main() {
  Future<void> pumpHub(WidgetTester tester, {FakeAuthGateway? gateway}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
          authGatewayProvider.overrideWithValue(gateway ?? FakeAuthGateway()),
          accountFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const StudyScreenV2(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('hub shows greeting, avatar and full-width cards',
      (tester) async {
    await pumpHub(tester);

    // Contextual greeting header (title + subtitle rotate daily).
    expect(find.byKey(const Key('studyGreetingTitle')), findsOneWidget);
    expect(find.byKey(const Key('studyGreetingSubtitle')), findsOneWidget);
    expect(find.byType(AccountAvatar), findsOneWidget);
    // Streak lives as a hub card (flame icon + progress CTA), not a
    // header pill.
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(find.text('Start your streak'), findsOneWidget);
    // Cards render (Your Space banner + tool cards + merged plans).
    expect(find.text('Bookmarks, highlights, notes & journal'), findsOneWidget);
    expect(find.text('Words defined'), findsOneWidget);
    // Plans widget with no active plan: pitch + "Pick a plan".
    expect(find.text('Read the Bible with a plan'), findsOneWidget);
    expect(find.text('Pick a plan'), findsOneWidget);
  });

  // Symmetry: Full cards own the whole content width, Half cards split it
  // evenly, paired halves share top edge and height, and every row in the
  // column sits on the same 12dp rhythm. Cards that shrink-wrap to their
  // text used to break this (Full rendering narrower than Full).
  testWidgets('hub cards keep one width system top to bottom', (tester) async {
    // Phone-sized viewport: 360dp wide, so card widths are stable numbers.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await pumpHub(tester);

    final cards = <RenderBox>[
      for (final e in find.byType(V2Card).evaluate())
        e.renderObject! as RenderBox,
    ];
    expect(cards, isNotEmpty);

    Offset origin(RenderBox b) => b.localToGlobal(Offset.zero);
    final contentLeft = origin(cards.first).dx;
    final contentRight = contentLeft + cards.first.size.width;

    // Group cards by row (same top edge).
    final rows = <double, List<RenderBox>>{};
    for (final c in cards) {
      rows.putIfAbsent(origin(c).dy, () => []).add(c);
    }

    for (final entry in rows.entries) {
      final row = entry.value;
      final widths = {for (final c in row) c.size.width.roundToDouble()};
      expect(widths.length, 1,
          reason: 'row at y=${entry.key} has unequal card widths $widths');
      final sorted = [for (final c in row) origin(c).dx]..sort();
      expect(sorted.first, moreOrLessEquals(contentLeft, epsilon: 0.5),
          reason: 'row at y=${entry.key} does not start at the content edge');
      final last = row.firstWhere((c) => origin(c).dx == sorted.last);
      expect(origin(last).dx + last.size.width,
          moreOrLessEquals(contentRight, epsilon: 0.5),
          reason: 'row at y=${entry.key} does not reach the content edge');
    }

    // Uniform vertical rhythm: the gaps between rows are all equal.
    final tops = rows.keys.toList()..sort();
    final gaps = <double>[];
    for (var i = 1; i < tops.length; i++) {
      final above = rows[tops[i - 1]]!;
      final bottom = origin(above.first).dy + above.first.size.height;
      gaps.add(tops[i] - bottom);
    }
    for (final g in gaps) {
      expect(g, moreOrLessEquals(gaps.first, epsilon: 0.5),
          reason: 'uneven row gaps: $gaps');
    }
  });

  testWidgets('avatar opens the account menu with data rows', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.byType(AccountAvatar));
    // Bottom-sheet entrance needs real frames (animated background
    // never settles: timed pumps, not pumpAndSettle).
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Signed out: guest header + sign-in rows. Apple sign-in is offered
    // only where it works (iOS/macOS), so not on this Android-like device.
    expect(find.text('Guest'), findsOneWidget);
    // "ACCOUNT" appears as the eyebrow label inside the hero card.
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Back up data'), findsOneWidget);
    expect(find.text('Restore data'), findsOneWidget);
    expect(find.text('Reset this device'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsNothing);
  });

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(AccountAvatar));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('Apple sign-in is offered where available', (tester) async {
    await pumpHub(tester,
        gateway: FakeAuthGateway(isAppleSignInAvailable: true));
    await openMenu(tester);
    expect(find.text('Sign in with Apple'), findsOneWidget);
  });

  testWidgets('signed-in user sees their name, email and sign-out',
      (tester) async {
    await pumpHub(tester,
        gateway: FakeAuthGateway(
            user: const AccountUser(
                uid: 'u1', displayName: 'Ruth', email: 'ruth@example.com')));
    await tester.pump();
    await openMenu(tester);
    expect(find.text('Ruth'), findsOneWidget);
    expect(find.text('ruth@example.com'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });

  Future<void> signOutWith(WidgetTester tester, {bool keepName = true}) async {
    await tester.ensureVisible(find.text('Sign out'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sign out'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    // One sheet, two choices, both ticked by default.
    expect(find.text('Keep my study data on this device'), findsOneWidget);
    expect(find.text('Keep my name on this device'), findsOneWidget);
    if (!keepName) {
      await tester.tap(find.text('Keep my name on this device'));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pump(const Duration(milliseconds: 300));
    // Pending uploads finish behind a progress dialog, never a frozen sheet.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('sign-out keeps the name and becomes a guest', (tester) async {
    final gateway = FakeAuthGateway(
        user: const AccountUser(uid: 'u1', displayName: 'Ruth'));
    await pumpHub(tester, gateway: gateway);
    await tester.pump();
    await openMenu(tester);
    expect(
        find.byIcon(Icons.cloud_done_outlined).evaluate().isNotEmpty ||
            find.text('Syncing…').evaluate().isNotEmpty,
        isTrue,
        reason: 'signed-in menu shows the sync row');

    await signOutWith(tester);
    expect(gateway.calls, contains('signOut'));
    expect(
        find.text("Signed out. You're using the app as Ruth."), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Back in the menu as a guest who kept their name.
    await openMenu(tester);
    expect(find.text('Ruth'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('sign-out can drop the name', (tester) async {
    final gateway = FakeAuthGateway(
        user: const AccountUser(uid: 'u1', displayName: 'Ruth'));
    await pumpHub(tester, gateway: gateway);
    await tester.pump();
    await openMenu(tester);
    await signOutWith(tester, keepName: false);
    expect(find.text("Signed out. You're using the app as a guest."),
        findsOneWidget);
    await openMenu(tester);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Add your name'), findsOneWidget);
  });

  testWidgets('a guest can name themselves', (tester) async {
    await pumpHub(tester);
    await openMenu(tester);
    await tester.tap(find.text('Add your name'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), '  Hadassah ');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hadassah'), findsOneWidget);
    expect(find.text('Guest'), findsNothing);
  });

  testWidgets('failed sign-in explains why and keeps the menu open',
      (tester) async {
    final gateway = FakeAuthGateway()
      ..signInError = const SignInFailedException(
          SignInFailure.network, 'network-request-failed');
    await pumpHub(tester, gateway: gateway);
    await openMenu(tester);
    await tester.ensureVisible(find.text('Sign in with Google'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(const SignInResult.failed(SignInFailure.network).message),
        findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('Google sign-in signs in and closes the menu', (tester) async {
    final gateway = FakeAuthGateway(
        nextUser: const AccountUser(uid: 'u1', displayName: 'Ruth'));
    await pumpHub(tester, gateway: gateway);
    await openMenu(tester);
    await tester.ensureVisible(find.text('Sign in with Google'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(gateway.calls, ['google']);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  Future<void> openReset(WidgetTester tester) async {
    await openMenu(tester);
    // The sheet scrolls on short viewports: bring the row into view.
    await tester.dragUntilVisible(
      find.text('Reset this device'),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -200),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Reset this device'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('guest reset erases this device only', (tester) async {
    await pumpHub(tester);
    await openReset(tester);

    expect(find.text('Erases on this device:'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    // Nothing in the cloud to offer deleting while signed out.
    expect(find.text('Also delete my cloud data'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Reset this device'));
    // The wipe touches real storage: give it real time, frame by frame.
    for (var i = 0;
        i < 80 && find.text('This device has been reset.').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('This device has been reset.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('cloud delete is a separate switch that needs DELETE typed',
      (tester) async {
    await pumpHub(tester,
        gateway: FakeAuthGateway(
            user: const AccountUser(uid: 'u1', displayName: 'Ruth')));
    await tester.pump();
    await openReset(tester);

    expect(find.text('Sign out and reset'), findsOneWidget);
    expect(find.text('Stay signed in and re-download'), findsOneWidget);
    final cloud = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(cloud.value, isFalse, reason: 'cloud delete is off by default');

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.text('Reset and delete cloud data'), findsOneWidget);
    await tester.tap(find.text('Reset and delete cloud data'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Delete your cloud data?'), findsOneWidget);
    FilledButton confirm() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete cloud data'));
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
  });
}
