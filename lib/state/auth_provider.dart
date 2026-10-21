import 'package:blessed_account/blessed_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import '../ui/widgets/restore_prompt.dart';
import 'journal_provider.dart';
import 'notes_provider.dart';
import 'user_data_provider.dart';

export 'package:blessed_account/blessed_account.dart'
    show
        AccountUser,
        SignInCancelledException,
        SignInFailedException,
        SignInResult,
        SignInStatus,
        accountServiceProvider,
        accountUserProvider,
        appleSignInAvailableProvider,
        authGatewayProvider;

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
        ref
          ..invalidate(bookmarkDataProvider)
          ..invalidate(highlightsProvider)
          ..invalidate(notesProvider)
          ..invalidate(journalProvider);
        await _setSignedOutByUser(true);
      });
}
