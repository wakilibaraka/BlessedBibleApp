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
      egwFile = File('local-data/egw_genesis.json');
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      egwFile = File('${docDir.path}/egw/egw_genesis.json');
    }

    if (!await egwFile.exists()) {
      return result; // Empty map if not found
    }

    final jsonString = await egwFile.readAsString();
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    if (!jsonData.containsKey('commentaries')) return result;
    
    final List<dynamic> commentaries = jsonData['commentaries'];
    
    for (var item in commentaries) {
      final String book = item['book']?.toString() ?? 'Genesis';
      final String chapter = item['chapter']?.toString() ?? '1';
      final String verseStart = item['verseStart']?.toString() ?? '1';
      final String id = item['id']?.toString() ?? '';
      final String commentary = item['commentary']?.toString() ?? '';
      final String sourceReference = item['sourceReference']?.toString() ?? 'Unknown Source';

      result.putIfAbsent(book, () => {});
      result[book]!.putIfAbsent(chapter, () => {});
      result[book]![chapter]!.putIfAbsent(verseStart, () => []);

      result[book]![chapter]![verseStart]!.add(CommentaryEntry(
        id: id,
        title: 'ELLEN G. WHITE - $sourceReference',
        text: commentary,
      ));
    }
  } catch (e) {
    debugPrint('Failed to load EGW commentary: $e');
  }

  return result;
});
