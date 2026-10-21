// "Welcome back" prompt after a reinstall: shown only when this device
// remembers an account, nobody is signed in and the user didn't sign out.

import 'package:blessed_account/blessed_account.dart';
import 'package:blessed_account/testing.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/l10n/generated/app_localizations.dart';
import 'package:the_blessed_bible/state/auth_provider.dart' hide AccountUser;
import 'package:the_blessed_bible/sync/bible_sync.dart';
import 'package:the_blessed_bible/ui/widgets/restore_prompt.dart';

void main() {
  const user = AccountUser(uid: 'u1', email: 'a@b.c', displayName: 'A');

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('shouldShow', () {
    test('remembered account, signed out, not dismissed', () async {
      final prefs = await prefsWith({SyncController.lastUidKey: 'u1'});
      expect(RestorePrompt.shouldShow(prefs, null), isTrue);
    });

    test('never on a device that has not had an account', () async {
      final prefs = await prefsWith({});
      expect(RestorePrompt.shouldShow(prefs, null), isFalse);
    });

    test('not when signed in', () async {
      final prefs = await prefsWith({SyncController.lastUidKey: 'u1'});
      expect(RestorePrompt.shouldShow(prefs, user), isFalse);
    });

    test('not after a deliberate sign-out', () async {
      final prefs = await prefsWith({
        SyncController.lastUidKey: 'u1',
        RestorePrompt.signedOutKey: true,
      });
      expect(RestorePrompt.shouldShow(prefs, null), isFalse);
    });

    test('not after the user said "Not now"', () async {
      final prefs = await prefsWith({
        SyncController.lastUidKey: 'u1',
        RestorePrompt.dismissedKey: true,
      });
      expect(RestorePrompt.shouldShow(prefs, null), isFalse);
    });
  });

  test('sign-out marks the user as gone on purpose; sign-in clears it',
      () async {
    final prefs = await prefsWith({SyncController.lastUidKey: 'u1'});
    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      authGatewayProvider.overrideWithValue(FakeAuthGateway()),
      accountFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
    ]);
    addTearDown(container.dispose);
    final actions = container.read(authActionsProvider);

    await actions.signOut();
    expect(prefs.getBool(RestorePrompt.signedOutKey), isTrue);
    expect(RestorePrompt.shouldShow(prefs, null), isFalse);

    await prefs.setBool(RestorePrompt.dismissedKey, true);
    final result = await actions.signInWithGoogle();
    expect(result.isSuccess, isTrue);
    expect(prefs.containsKey(RestorePrompt.signedOutKey), isFalse);
    expect(prefs.containsKey(RestorePrompt.dismissedKey), isFalse);
  });

  Future<SharedPreferences> pumpHost(
    WidgetTester tester,
    Map<String, Object> values,
  ) async {
    final prefs = await prefsWith(values);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
          authGatewayProvider.overrideWithValue(FakeAuthGateway()),
          accountFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RestorePromptHost(child: Scaffold(body: Text('home'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return prefs;
  }

  testWidgets('offers sign-in once and remembers "Not now"', (tester) async {
    final prefs = await pumpHost(tester, {SyncController.lastUidKey: 'u1'});

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsNothing);
    expect(prefs.getBool(RestorePrompt.dismissedKey), isTrue);
  });

  testWidgets('stays quiet on a fresh install', (tester) async {
    await pumpHost(tester, {});
    expect(find.text('Welcome back'), findsNothing);
  });
}
