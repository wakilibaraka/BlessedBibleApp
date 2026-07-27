import 'package:flutter/material.dart';

enum BibleSection {
  pentateuch,
  historical,
  wisdom,
  majorProphets,
  minorProphetsPreExilic,
  minorProphetsPostExilic,
  gospels,
  acts,
  epistlesPauline,
  epistlesPetrine,
  epistlesJohannine,
  epistleHebrews,
  epistleJames,
  epistleJude,
  revelation,
}

const Map<String, BibleSection> _bookSections = {
  'Genesis': BibleSection.pentateuch,
  'Exodus': BibleSection.pentateuch,
  'Leviticus': BibleSection.pentateuch,
  'Numbers': BibleSection.pentateuch,
  'Deuteronomy': BibleSection.pentateuch,
  'Joshua': BibleSection.historical,
  'Judges': BibleSection.historical,
  'Ruth': BibleSection.historical,
  '1 Samuel': BibleSection.historical,
  '2 Samuel': BibleSection.historical,
  '1 Kings': BibleSection.historical,
  '2 Kings': BibleSection.historical,
  '1 Chronicles': BibleSection.historical,
  '2 Chronicles': BibleSection.historical,
  'Ezra': BibleSection.historical,
  'Nehemiah': BibleSection.historical,
  'Esther': BibleSection.historical,
  'Job': BibleSection.wisdom,
  'Psalms': BibleSection.wisdom,
  'Proverbs': BibleSection.wisdom,
  'Ecclesiastes': BibleSection.wisdom,
  'Song of Solomon': BibleSection.wisdom,
  'Isaiah': BibleSection.majorProphets,
  'Jeremiah': BibleSection.majorProphets,
  'Lamentations': BibleSection.majorProphets,
  'Ezekiel': BibleSection.majorProphets,
  'Daniel': BibleSection.majorProphets,
  'Hosea': BibleSection.minorProphetsPreExilic,
  'Joel': BibleSection.minorProphetsPreExilic,
  'Amos': BibleSection.minorProphetsPreExilic,
  'Obadiah': BibleSection.minorProphetsPreExilic,
  'Jonah': BibleSection.minorProphetsPreExilic,
  'Micah': BibleSection.minorProphetsPreExilic,
  'Nahum': BibleSection.minorProphetsPreExilic,
  'Habakkuk': BibleSection.minorProphetsPreExilic,
  'Zephaniah': BibleSection.minorProphetsPreExilic,
  'Haggai': BibleSection.minorProphetsPostExilic,
  'Zechariah': BibleSection.minorProphetsPostExilic,
  'Malachi': BibleSection.minorProphetsPostExilic,
  'Matthew': BibleSection.gospels,
  'Mark': BibleSection.gospels,
  'Luke': BibleSection.gospels,
  'John': BibleSection.gospels,
  'Acts': BibleSection.acts,
  'Romans': BibleSection.epistlesPauline,
  '1 Corinthians': BibleSection.epistlesPauline,
  '2 Corinthians': BibleSection.epistlesPauline,
  'Galatians': BibleSection.epistlesPauline,
  'Ephesians': BibleSection.epistlesPauline,
  'Philippians': BibleSection.epistlesPauline,
  'Colossians': BibleSection.epistlesPauline,
  '1 Thessalonians': BibleSection.epistlesPauline,
  '2 Thessalonians': BibleSection.epistlesPauline,
  '1 Timothy': BibleSection.epistlesPauline,
  '2 Timothy': BibleSection.epistlesPauline,
  'Titus': BibleSection.epistlesPauline,
  'Philemon': BibleSection.epistlesPauline,
  'Hebrews': BibleSection.epistleHebrews,
  'James': BibleSection.epistleJames,
  '1 Peter': BibleSection.epistlesPetrine,
  '2 Peter': BibleSection.epistlesPetrine,
  '1 John': BibleSection.epistlesJohannine,
  '2 John': BibleSection.epistlesJohannine,
  '3 John': BibleSection.epistlesJohannine,
  'Jude': BibleSection.epistleJude,
  'Revelation': BibleSection.revelation,
};

Color getSectionColor(String bookName, bool isDark) {
  final section = _bookSections[bookName] ?? BibleSection.historical;
  
  // Tasteful tones fitting the cream/gold aesthetic
  switch (section) {
    case BibleSection.pentateuch: return isDark ? const Color(0xFF383127) : const Color(0xFFF6ECE1);
    case BibleSection.historical: return isDark ? const Color(0xFF323632) : const Color(0xFFE9F0E9);
    case BibleSection.wisdom: return isDark ? const Color(0xFF36323B) : const Color(0xFFECE7F1);
    case BibleSection.majorProphets: return isDark ? const Color(0xFF3A2D2D) : const Color(0xFFF3E5E5);
    case BibleSection.minorProphetsPreExilic: return isDark ? const Color(0xFF383129) : const Color(0xFFF1E9E1);
    case BibleSection.minorProphetsPostExilic: return isDark ? const Color(0xFF353328) : const Color(0xFFF0EBE0);
    case BibleSection.gospels: return isDark ? const Color(0xFF3C3322) : const Color(0xFFF6EEE0);
    case BibleSection.acts: return isDark ? const Color(0xFF2A343A) : const Color(0xFFE4EDF1);
    case BibleSection.epistlesPauline: return isDark ? const Color(0xFF3A362D) : const Color(0xFFF4F0E5);
    case BibleSection.epistlesPetrine: return isDark ? const Color(0xFF2D363A) : const Color(0xFFE5F0F4);
    case BibleSection.epistlesJohannine: return isDark ? const Color(0xFF362D3A) : const Color(0xFFF0E5F4);
    case BibleSection.epistleHebrews: return isDark ? const Color(0xFF313A2D) : const Color(0xFFEBF4E5);
    case BibleSection.epistleJames: return isDark ? const Color(0xFF3A312A) : const Color(0xFFF4EBE0);
    case BibleSection.epistleJude: return isDark ? const Color(0xFF303032) : const Color(0xFFEAEAEA);
    case BibleSection.revelation: return isDark ? const Color(0xFF3C2A30) : const Color(0xFFF5E3E7);
  }
}
