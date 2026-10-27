import 'package:blessed_account/blessed_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import '../ui/widgets/restore_prompt.dart';
import 'journal_provider.dart';
import 'notes_provider.dart';
import 'profile_provider.dart';
import 'user_data_provider.dart';

export 'package:blessed_account/blessed_account.dart'
    show
        AccountUser,
        SharedProfile,
        SignInCancelledException,
        SignInFailedException,
        SignInResult,
        SignInStatus,
        accountFirestoreProvider,
        accountServiceProvider,
        accountUserProvider,
        appleSignInAvailableProvider,
        authGatewayProvider,
        sharedProfileProvider;

/// The Bible app's account actions, on top of the shared `blessed_account`
/// package (same account as Blessed Arcade).
final authActionsProvider = Provider<AuthActions>(AuthActions.new);

class AuthActions {
  final Ref ref;
  AuthActions(this.ref);

  AccountService get _account => ref.read(accountServiceProvider);

  Future<SignInResult> signInWithGoogle() async =>
      _rememberSignIn(await _account.signInWithGoogle());

  Future<SignInResult> signInWithApple() async =>
      _rememberSignIn(await _account.signInWithApple());

  /// Saves the name shown for this user: on this device for a guest, on
  /// the shared account profile (also Blessed Arcade's) when signed in.
  /// Throws if the account can't be reached.
  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    final user = ref.read(accountUserProvider).value;
    if (user == null) {
      await ref.read(guestNameProvider.notifier).set(trimmed);
    } else if (trimmed.isNotEmpty) {
      await _account.profiles.ensureExists(user);
      await _account.profiles.update(user.uid, displayName: trimmed);
    }
  }

  /// A deliberate sign-out; keeps the "welcome back" prompt from nagging.
  Future<void> signOut() async {
    await _account.signOut();
    await _setSignedOutByUser(true);
  }

  SignInResult _rememberSignIn(SignInResult result) {
    if (result.isSuccess) {
      final prefs = ref.read(preferencesProvider).prefs;
      prefs.remove(RestorePrompt.signedOutKey);
      prefs.remove(RestorePrompt.dismissedKey);
    }
    return result;
  }

  Future<void> _setSignedOutByUser(bool value) async {
    await ref
        .read(preferencesProvider)
        .prefs
        .setBool(RestorePrompt.signedOutKey, value);
  }

  /// Deletes the account, both apps' cloud data and this device's study
  /// data. Throws [SignInCancelledException] if the user dismisses the
  /// re-authentication prompt (nothing is deleted).
  Future<void> deleteAccount() =>
      _account.deleteAccount(clearLocalData: () async {
        await ref.read(preferencesProvider).clearAllUserData();
        await ref.read(guestNameProvider.notifier).set(null);
        ref
          ..invalidate(bookmarkDataProvider)
          ..invalidate(highlightsProvider)
          ..invalidate(notesProvider)
          ..invalidate(journalProvider);
        await _setSignedOutByUser(true);
      });
}
