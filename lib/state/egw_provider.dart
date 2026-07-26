import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/commentary_model.dart';
import '../utils/isolate_parsers.dart';

final egwCommentaryProvider = FutureProvider<Map<String, Map<String, Map<String, List<CommentaryEntry>>>>>((ref) async {
  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> result = {};

  try {
    File egwFile;
    if (Platform.isAndroid || Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      egwFile = File('${docDir.path}/egw_genesis.json');
    } else {
      egwFile = File('${Directory.current.path}/local-data/egw_genesis.json');
    }

    debugPrint('EGW Path: ${egwFile.path} | existsSync: ${egwFile.existsSync()}');

    if (!await egwFile.exists()) {
      return result; // Empty map if not found
    }

    final jsonString = await egwFile.readAsString();
    result = await compute(parseEgwJson, jsonString);
  } catch (e) {
    debugPrint('Failed to load EGW commentary: $e');
  }

  return result; // Return empty map instead of throwing if parsing fails
});
