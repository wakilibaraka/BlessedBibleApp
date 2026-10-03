import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ContentSyncService<T> {
  final String collectionName;
  final String cacheFileName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  ContentSyncService({
    required this.collectionName,
    required this.cacheFileName,
    required this.fromJson,
    required this.toJson,
  });

  /// Loads cached data from the local file system.
  Future<Map<String, T>> loadLocalCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$cacheFileName');
      if (!await file.exists()) return {};

      final jsonString = await file.readAsString();
      final decoded = await compute(_parseJsonMap, jsonString);
      
      final Map<String, T> result = {};
      final entries = decoded['data'] as Map<String, dynamic>? ?? {};
      for (final entry in entries.entries) {
        result[entry.key] = fromJson(entry.value as Map<String, dynamic>);
      }
      return result;
    } catch (e) {
      debugPrint('Error loading local cache for $collectionName: $e');
      return {};
    }
  }

  /// Fire-and-forget background sync from Firestore.
  /// Notifies via [onUpdate] if new deltas were found and cached.
  Future<void> syncDeltas(void Function(Map<String, T> newCache) onUpdate) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$cacheFileName');
      
      Map<String, dynamic> currentCache = {'lastSync': 0, 'data': {}};
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        currentCache = await compute(_parseJsonMap, jsonString);
      }

      final lastSyncMillis = currentCache['lastSync'] as int? ?? 0;
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      final lastSyncTimestamp = Timestamp.fromDate(lastSyncDate);

      // Query Firestore for newer docs
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('updatedAt', isGreaterThan: lastSyncTimestamp)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return; // No updates
      }

      // Merge new data
      final dataMap = currentCache['data'] as Map<String, dynamic>? ?? {};
      for (final doc in querySnapshot.docs) {
        dataMap[doc.id] = doc.data();
      }

      final Map<String, dynamic> cleanDataMap = {};
      final Map<String, T> parsedResult = {};
      
      for (final entry in dataMap.entries) {
         try {
           final parsed = fromJson(entry.value as Map<String, dynamic>);
           parsedResult[entry.key] = parsed;
           cleanDataMap[entry.key] = toJson(parsed);
         } catch (e) {
           debugPrint('Error parsing doc ${entry.key}: $e');
         }
      }

      final newCache = {
        'lastSync': DateTime.now().millisecondsSinceEpoch,
        'data': cleanDataMap,
      };

      // Encode and save
      final encodedString = await compute(_encodeJsonMap, newCache);
      await file.writeAsString(encodedString);

      // Notify caller
      onUpdate(parsedResult);
      
    } catch (e) {
      debugPrint('Error syncing $collectionName: $e');
      // Silently swallow network/firestore errors
    }
  }
}

// Top-level functions for compute
Map<String, dynamic> _parseJsonMap(String jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>;
String _encodeJsonMap(Map<String, dynamic> data) => jsonEncode(data);
