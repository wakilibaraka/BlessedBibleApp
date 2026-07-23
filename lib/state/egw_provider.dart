import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/commentary_model.dart';

final egwCommentaryProvider = FutureProvider<Map<String, Map<String, Map<String, List<CommentaryEntry>>>>>((ref) async {
  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> result = {};

  try {
    File egwFile;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final projectDir = Platform.environment['PWD'] ?? Directory.current.path;
      egwFile = File('$projectDir/local-data/egw_genesis.json');
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      egwFile = File('${docDir.path}/egw/egw_genesis.json');
    }

    if (!await egwFile.exists()) {
      return result; // Empty map if not found
    }

    final jsonString = await egwFile.readAsString();
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    for (var bookEntry in jsonData.entries) {
      final String book = bookEntry.key;
      result.putIfAbsent(book, () => {});
      final Map<String, dynamic> chapters = bookEntry.value;
      
      for (var chapterEntry in chapters.entries) {
        final String chapter = chapterEntry.key;
        result[book]!.putIfAbsent(chapter, () => {});
        final Map<String, dynamic> verses = chapterEntry.value;
        
        for (var verseEntry in verses.entries) {
          final String verse = verseEntry.key;
          result[book]![chapter]!.putIfAbsent(verse, () => []);
          final List<dynamic> comments = verseEntry.value;
          
          for (var item in comments) {
            final entryMap = item as Map<String, dynamic>;
            result[book]![chapter]![verse]!.add(CommentaryEntry(
              id: entryMap['id']?.toString() ?? '',
              title: 'ELLEN G. WHITE - ${entryMap['title']?.toString() ?? 'Commentary'}',
              text: entryMap['text']?.toString() ?? '',
            ));
          }
        }
      }
    }
  } catch (e) {
    debugPrint('Failed to load EGW commentary: $e');
  }

  return result;
});
