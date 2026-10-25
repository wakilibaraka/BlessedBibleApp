import 'dart:typed_data';

import 'package:gal/gal.dart';

import '../utils/log.dart';

/// Outcome of a save so the UI can say what actually happened.
enum GallerySaveResult { saved, permissionDenied, failed }

/// Saves generated images (share cards) to the device photo library.
///
/// The only native plugin in the sharing stack: gallery writes need platform
/// APIs. Permission is requested on demand, and a denied permission is
/// reported back rather than swallowed.
class GalleryService {
  /// Saves [bytes] as a PNG named [name] (no extension).
  static Future<GallerySaveResult> savePng(
    Uint8List bytes, {
    required String name,
  }) async {
    try {
      var access = await Gal.hasAccess();
      if (!access) access = await Gal.requestAccess();
      if (!access) return GallerySaveResult.permissionDenied;
      await Gal.putImageBytes(bytes, name: name);
      return GallerySaveResult.saved;
    } on GalException catch (e) {
      logDebug('Gallery save failed: ${e.type.message}');
      return e.type == GalExceptionType.accessDenied
          ? GallerySaveResult.permissionDenied
          : GallerySaveResult.failed;
    } catch (e) {
      logDebug('Gallery save failed: $e');
      return GallerySaveResult.failed;
    }
  }
}
