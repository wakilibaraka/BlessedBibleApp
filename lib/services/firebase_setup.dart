import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../utils/log.dart';

/// Routes uncaught Flutter and platform errors to Crashlytics.
///
/// Collection is off in debug builds and whenever the user turned off
/// "Send crash reports" in Settings ([enabled] = false). Call after
/// `Firebase.initializeApp`.
Future<void> initCrashReporting({required bool enabled}) async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(enabled && !kDebugMode);

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
      return;
    }
    crashlytics.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logDebug('Uncaught async error: $error\n$stack');
    if (!kDebugMode) {
      crashlytics.recordError(error, stack, fatal: true);
    }
    return true; // Handled; keep the app running.
  };
}

/// Records a handled problem (no personal data) as a non-fatal Crashlytics
/// report, e.g. why a sign-in failed. Release builds only; respects the
/// user's crash-report choice.
void reportNonFatal(String reason, {String? code}) {
  logDebug('$reason (${code ?? '-'})');
  if (kDebugMode) return;
  try {
    FirebaseCrashlytics.instance.recordError(
      Exception(code == null ? reason : '$reason: $code'),
      StackTrace.current,
      reason: reason,
    );
  } catch (_) {
    // Reporting must never break the caller.
  }
}

/// Applies the user's "Send crash reports" choice immediately.
Future<void> setCrashReportingEnabled(bool enabled) =>
    FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(enabled && !kDebugMode);

/// Attests requests to Firebase (Firestore, Auth) as coming from this app.
///
/// Debug builds use the debug provider: the token printed in the device log
/// must be registered under App Check > Apps > Manage debug tokens in the
/// Firebase console. Enforcement is switched on per service in the console.
Future<void> activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
  } catch (e) {
    logDebug('App Check activation failed: $e');
  }
}
