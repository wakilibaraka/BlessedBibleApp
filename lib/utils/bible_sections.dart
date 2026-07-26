import 'package:flutter/material.dart';

enum BibleSection {
  pentateuch,
  historical,
  wisdom,
  majorProphets,
  minorProphets,
  gospels,
  acts,
  epistles,
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
  'Hosea': BibleSection.minorProphets,
  'Joel': BibleSection.minorProphets,
  'Amos': BibleSection.minorProphets,
  'Obadiah': BibleSection.minorProphets,
  'Jonah': BibleSection.minorProphets,
  'Micah': BibleSection.minorProphets,
  'Nahum': BibleSection.minorProphets,
  'Habakkuk': BibleSection.minorProphets,
  'Zephaniah': BibleSection.minorProphets,
  'Haggai': BibleSection.minorProphets,
  'Zechariah': BibleSection.minorProphets,
  'Malachi': BibleSection.minorProphets,
  'Matthew': BibleSection.gospels,
  'Mark': BibleSection.gospels,
  'Luke': BibleSection.gospels,
  'John': BibleSection.gospels,
  'Acts': BibleSection.acts,
  'Romans': BibleSection.epistles,
  '1 Corinthians': BibleSection.epistles,
  '2 Corinthians': BibleSection.epistles,
  'Galatians': BibleSection.epistles,
  'Ephesians': BibleSection.epistles,
  'Philippians': BibleSection.epistles,
  'Colossians': BibleSection.epistles,
  '1 Thessalonians': BibleSection.epistles,
  '2 Thessalonians': BibleSection.epistles,
  '1 Timothy': BibleSection.epistles,
  '2 Timothy': BibleSection.epistles,
  'Titus': BibleSection.epistles,
  'Philemon': BibleSection.epistles,
  'Hebrews': BibleSection.epistles,
  'James': BibleSection.epistles,
  '1 Peter': BibleSection.epistles,
  '2 Peter': BibleSection.epistles,
  '1 John': BibleSection.epistles,
  '2 John': BibleSection.epistles,
  '3 John': BibleSection.epistles,
  'Jude': BibleSection.epistles,
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
    case BibleSection.minorProphets: return isDark ? const Color(0xFF383129) : const Color(0xFFF1E9E1);
    case BibleSection.gospels: return isDark ? const Color(0xFF3C3322) : const Color(0xFFF6EEE0);
    case BibleSection.acts: return isDark ? const Color(0xFF2A343A) : const Color(0xFFE4EDF1);
    case BibleSection.epistles: return isDark ? const Color(0xFF3A362D) : const Color(0xFFF4F0E5);
    case BibleSection.revelation: return isDark ? const Color(0xFF3C2A30) : const Color(0xFFF5E3E7);
  }
}
