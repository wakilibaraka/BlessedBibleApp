import 'package:flutter/foundation.dart';

/// Debug-only logging. Silent in profile and release builds, so error
/// details never reach device logs in production.
void logDebug(String message) {
  if (kDebugMode) debugPrint(message);
}
