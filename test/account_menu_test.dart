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
    // Merged plans_live card (no active plans -> start CTA page).
    expect(find.text('Start a reading plan'), findsOneWidget);
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
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Back up data'), findsOneWidget);
    expect(find.text('Restore data'), findsOneWidget);
    expect(find.text('Reset app'), findsOneWidget);
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
    expect(find.text('Sign Out'), findsOneWidget);
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

  testWidgets('reset row asks for confirmation', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.byType(AccountAvatar));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // The sheet scrolls on short viewports: bring the row into view.
    await tester.dragUntilVisible(
      find.text('Reset app'),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -200),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Reset app'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Reset app?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
