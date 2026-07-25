import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// A centralized service for formatting and sharing Bible content.
/// Future share types (e.g., sharing a note, highlighted verse, or image/quote card)
/// should be added here as new methods to avoid cluttering UI call sites.
class ShareService {
  /// Formats selected verses into a single readable string.
  /// Example: "In the beginning... — Genesis 1:1"
  static String formatVerses({
    required String bookName,
    required int chapterNumber,
    required List<int> verseNumbers,
    required dynamic chapterData, // Expected to have a `.verses` list with `.text`
  }) {
    if (verseNumbers.isEmpty) return '';
    final sorted = verseNumbers.toList()..sort();
    final texts = sorted.map((v) {
      if (v - 1 >= 0 && v - 1 < chapterData.verses.length) {
        final text = chapterData.verses[v - 1].text;
        return sorted.length > 1 ? '$v. $text' : text;
      }
      return '';
    }).where((t) => t.isNotEmpty).join(' ');

    String refStr;
    if (sorted.length == 1) {
      refStr = '$bookName $chapterNumber:${sorted.first}';
    } else {
      bool isContiguous = true;
      for (int i = 0; i < sorted.length - 1; i++) {
        if (sorted[i + 1] - sorted[i] != 1) {
          isContiguous = false;
          break;
        }
      }
      if (isContiguous) {
        refStr = '$bookName $chapterNumber:${sorted.first}-${sorted.last}';
      } else {
        refStr = '$bookName $chapterNumber:${sorted.join(', ')}';
      }
    }

    return '$texts — $refStr';
  }

  /// Copies text to clipboard and shows a confirmation SnackBar.
  static Future<void> copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
      );
    }
  }

  /// Shares text via native share sheet using share_plus.
  static Future<void> shareText({required String body, String? subject}) async {
    try {
      // Ignore deprecation warning if SharePlus is not the correct API or use Share
      // ignore: deprecated_member_use
      await Share.share(body, subject: subject);
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }
}
