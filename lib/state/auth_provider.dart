import 'package:blessed_account/blessed_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';

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

  Future<SignInResult> signInWithGoogle() => _account.signInWithGoogle();

  Future<SignInResult> signInWithApple() => _account.signInWithApple();

  Future<void> signOut() => _account.signOut();

  /// Deletes the account, both apps' cloud data and this device's study
  /// data. Throws [SignInCancelledException] if the user dismisses the
  /// re-authentication prompt (nothing is deleted).
  Future<void> deleteAccount() => _account.deleteAccount(
      clearLocalData: () => ref.read(preferencesProvider).clearAllUserData());
}
