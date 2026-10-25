// Guards the shipped commentary pack. Part of it is OCR text scanned from
// 1890s printings; tool/clean_commentary.py repairs that damage, and these
// assertions keep the machine-repairable artifacts from creeping back in on the
// next import of a source book.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/commentary_work.dart';
import 'package:the_blessed_bible/utils/isolate_parsers.dart';

void main() {
  final data = jsonDecode(
    File('assets/commentary/commentary.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final entries =
      (data['entries'] as List<dynamic>).cast<Map<String, dynamic>>();

  String textOf(Map<String, dynamic> entry) => entry['text'] as String;

  String label(Map<String, dynamic> entry) {
    final scope = entry['scope'] as Map<String, dynamic>;
    return '${entry['id']} (${entry['source']} '
        '${scope['book']} ${scope['chapter']}:${scope['verse']})';
  }

  test('entry count matches the header', () {
    expect(data['count'], entries.length);
    expect(entries.length, greaterThan(4000),
        reason: 'the pack should not lose whole source books');
    for (final entry in entries) {
      expect(textOf(entry).trim(), isNotEmpty, reason: label(entry));
      expect(textOf(entry), textOf(entry).trim(), reason: label(entry));
    }
  });

  test('no HTML entities or scanner noise characters', () {
    final entity = RegExp(r'&(?:amp|gt|lt|quot|nbsp|#\d+);');
    final noise = RegExp(r'[\\|^~`¦●○◆•™©®«»¬]');
    for (final entry in entries) {
      final text = textOf(entry);
      expect(entity.hasMatch(text), isFalse, reason: label(entry));
      expect(noise.hasMatch(text), isFalse, reason: label(entry));
    }
  });

  test('no Project Gutenberg or printing furniture', () {
    final pageRange = RegExp(r'\[\s*\d{1,4}\s*[-–]\s*\d{1,4}\s*\]');
    const markers = [
      'PROJECT GUTENBERG',
      'Updated editions will replace',
      'Transcriber',
      'This chapter is based',
      'REVIEW AND HERALD',
      'Copyright',
      'ARTIST',
      '=NOTE',
      '**',
      '__',
    ];
    for (final entry in entries) {
      final text = textOf(entry);
      for (final marker in markers) {
        expect(text.contains(marker), isFalse,
            reason: '$marker in ${label(entry)}');
      }
      expect(pageRange.hasMatch(text), isFalse, reason: label(entry));
    }
  });

  test('the app parser reads every entry the cleaner kept', () {
    final parsed = parseCommentaryJson(
      File('assets/commentary/commentary.json').readAsStringSync(),
    );
    expect(parsed.length, entries.length);
    expect(parsed.every((e) => e.text.trim().isNotEmpty), isTrue);
    expect(
      parsed.where((e) => e.scope.book == 'Matthew').length,
      greaterThan(100),
      reason: 'a whole source book went missing',
    );
  });

  test('no control characters or stray soft hyphens', () {
    final control = RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]');
    final invisible = RegExp('[\u00ad\u200b\u200c\u200d\ufeff]');
    for (final entry in entries) {
      final text = textOf(entry);
      expect(control.hasMatch(text), isFalse, reason: label(entry));
      expect(invisible.hasMatch(text), isFalse, reason: label(entry));
    }
  });

  test('sources fold into the volumes the library shelves', () {
    final works = buildCommentaryWorks(parseCommentaryJson(
      File('assets/commentary/commentary.json').readAsStringSync(),
    ));
    final titles = works.map((w) => w.title).toSet();

    // An import that puts its verse range in the source must not produce a
    // hundred one-verse volumes again.
    for (final title in titles) {
      expect(title, isNot(contains(RegExp(r'\(\s*\d'))), reason: title);
      expect(title.endsWith(')'), isFalse, reason: title);
    }
    expect(
      titles,
      containsAll([
        'The Desire of Ages',
        'Prophets and Kings',
        'Patriarchs and Prophets',
        'The Acts of the Apostles',
        'Daniel and the Revelation',
        'The Book of Hebrews',
        'Waggoner on Romans',
        'The Glad Tidings',
      ]),
    );
    expect(
      titles.where((t) => t.startsWith('Daniel and the Revelation')).length,
      1,
    );
    final daniel =
        works.firstWhere((w) => w.title == 'Daniel and the Revelation');
    expect(daniel.books, ['Daniel', 'Revelation']);
    expect(daniel.entryCount, greaterThan(400));
  });
}
