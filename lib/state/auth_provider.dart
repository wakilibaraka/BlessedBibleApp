import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Streams the current Firebase auth state (null = signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provides sign-in/out actions (no state, just methods).
final authActionsProvider = Provider<AuthActions>((ref) => AuthActions());

enum SignInResult { success, cancelled, failed }

class AuthActions {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  /// Runs the Google sign-in flow and signs into Firebase.
  /// Returns [SignInResult.cancelled] if the user dismisses the picker,
  /// [SignInResult.failed] on any error, [SignInResult.success] on success.
  Future<SignInResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return SignInResult.cancelled;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return SignInResult.success;
    } catch (_) {
      return SignInResult.failed;
    }
  }

  /// Runs the Apple sign-in flow and signs into Firebase.
  Future<SignInResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
      return SignInResult.success;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return SignInResult.cancelled;
      }
      return SignInResult.failed;
    } catch (_) {
      return SignInResult.failed;
    }
  }

  /// Signs out of both Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Deletes the current user's account and signs out.
  /// Throws an exception if the deletion fails (e.g., requires recent sign-in).
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Note: If the user hasn't signed in recently, this will throw a
      // FirebaseAuthException (requires-recent-login). The UI must handle this.
      await user.delete();
      // user.delete() also signs them out of Firebase, but we should clear Google state too.
      await _googleSignIn.signOut();
    }
  }
}

