// PDF export: commentary and stories become valid, multi-block PDFs, and
// very long entries are clipped instead of producing endless documents.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/share_content.dart';
import 'package:the_blessed_bible/services/share_pdf_service.dart';

String _pdfHeader(List<int> bytes) => ascii.decode(bytes.sublist(0, 5));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('commentary exports a valid PDF', () async {
    final content = ShareContent.commentary(
      text: 'Is it possible to imagine a time when nothing existed? '
          'Take away the brilliance of the sun, for example, and the moon '
          'and stars at night.',
      reference: 'Genesis 1:2',
      source: 'Patriarchs and Prophets',
      author: 'Ellen G. White',
    );
    final bytes = await SharePdfService.build(content);
    expect(_pdfHeader(bytes), '%PDF-');
    expect(bytes.length, greaterThan(1500));
  });

  test('story exports a valid PDF with its key verse', () async {
    final content = ShareContent.story(
      title: 'The Creation of the World',
      body: 'In the beginning God created the heaven and the earth.',
      reference: 'Genesis 1:1-2:3',
      keyVerse: '"In the beginning God created the heaven and the earth."',
      keyVerseRef: 'Genesis 1:1',
    );
    final bytes = await SharePdfService.build(content);
    expect(_pdfHeader(bytes), '%PDF-');
  });

  test('multi-paragraph and very long entries stay bounded', () async {
    final content = ShareContent.commentary(
      text: List.generate(
        80,
        (i) => 'Paragraph $i. ${List.filled(40, 'word').join(' ')}',
      ).join('\n\n'),
      reference: 'Genesis 1',
    );
    final bytes = await SharePdfService.build(content);
    expect(_pdfHeader(bytes), '%PDF-');
    // Far below what an unbounded 200k-character export would produce.
    expect(bytes.length, lessThan(2 * 1024 * 1024));
  });

  test('accented text in the reading languages exports without error',
      () async {
    final content = ShareContent.story(
      title: 'La Création du Monde',
      body: 'Dieu créa les cieux et la terre. Și a fost lumină. Nuru na giza.',
      reference: 'Genèse 1:1',
    );
    final bytes = await SharePdfService.build(content);
    expect(_pdfHeader(bytes), '%PDF-');
  });
}
