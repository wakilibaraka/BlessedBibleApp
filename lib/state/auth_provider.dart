import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../data/local_storage/preferences_service.dart';

/// Streams the current Firebase auth state (null = signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provides sign-in/out actions (no state, just methods).
final authActionsProvider = Provider<AuthActions>((ref) => AuthActions(ref));

class ReauthCancelledException implements Exception {
  final String message;
  ReauthCancelledException([this.message = 'Re-authentication was cancelled.']);
  @override
  String toString() => message;
}

enum SignInResult { success, cancelled, failed }

class AuthActions {
  final Ref ref;
  final _auth = FirebaseAuth.instance;

  AuthActions(this.ref);

  /// Runs the Google sign-in flow and signs into Firebase.
  /// Returns [SignInResult.cancelled] if the user dismisses the picker,
  /// [SignInResult.failed] on any error, [SignInResult.success] on success.
  Future<SignInResult> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: null, // v7: idToken-only flow for Firebase
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return SignInResult.success;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return SignInResult.cancelled;
      }
      return SignInResult.failed;
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
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  /// Re-authenticates the current user (required before sensitive ops).
  Future<bool> _reauthenticate(User user) async {
    try {
      final isApple = user.providerData.any((p) => p.providerId == 'apple.com');
      if (isApple) {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        );
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(oauthCredential);
        return true;
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: null,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled || e.code == GoogleSignInExceptionCode.interrupted) {
        throw ReauthCancelledException();
      }
      return false;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw ReauthCancelledException();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _performDeletionSteps(User user) async {
    final uid = user.uid;
    final firestore = FirebaseFirestore.instance;

    // 1. Query users/{uid}/plans and batch-delete every plan document
    final plansRef = firestore.collection('users').doc(uid).collection('plans');
    final plansSnap = await plansRef.get();
    
    if (plansSnap.docs.isNotEmpty) {
      final batch = firestore.batch();
      for (final doc in plansSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    // 2. Delete the users/{uid} document itself
    await firestore.collection('users').doc(uid).delete();

    // 3. Delete the auth account
    await user.delete();

    // 4. Clear local user data
    await ref.read(preferencesProvider).clearAllUserData();

    // 5. Clear Google state
    await GoogleSignIn.instance.signOut();
  }

  /// Deletes the current user's account and signs out.
  /// Re-authenticates the user upfront before performing any deletion.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reauthed = await _reauthenticate(user);
    if (!reauthed) {
      throw Exception('Re-authentication required to delete your account.');
    }

    try {
      await _performDeletionSteps(user);
    } catch (e) {
      rethrow;
    }
  }
}

