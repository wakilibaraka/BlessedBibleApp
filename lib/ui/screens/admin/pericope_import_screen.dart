import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/isolate_parsers.dart';

class PericopeImportScreen extends StatefulWidget {
  const PericopeImportScreen({super.key});

  @override
  State<PericopeImportScreen> createState() => _PericopeImportScreenState();
}

class _PericopeImportScreenState extends State<PericopeImportScreen> {
  int _total = 0;
  int _completed = 0;
  bool _isRunning = false;
  String _status = 'Ready to import';

  Future<void> _startImport() async {
    setState(() {
      _isRunning = true;
      _status = 'Loading JSON...';
    });

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/pericopes.json');
      setState(() => _status = 'Parsing JSON off-thread...');

      final entries = await compute(parsePericopesJson, jsonString);

      setState(() {
        _total = entries.length;
        _completed = 0;
        _status = 'Writing to Firestore...';
      });

      final firestore = FirebaseFirestore.instance;
      // Batched writes limit is 500. We use 400 for safety margin.
      const batchSize = 400;

      for (int i = 0; i < entries.length; i += batchSize) {
        final end =
            (i + batchSize < entries.length) ? i + batchSize : entries.length;
        final batch = firestore.batch();

        for (int j = i; j < end; j++) {
          final entry = entries[j];
          final docId = entry.id; // Deterministic ID: {book}_{startCh}_{startV}
          final docRef = firestore.collection('pericopes').doc(docId);

          final data = entry.toJson();
          data['updatedAt'] = FieldValue.serverTimestamp();

          batch.set(docRef, data, SetOptions(merge: true));
        }

        await batch.commit();
        if (mounted) {
          setState(() => _completed = end);
        }
      }

      if (mounted) setState(() => _status = 'Import Complete!');
    } catch (e) {
      if (mounted) setState(() => _status = 'Error: $e');
    }

    if (mounted) setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pericope Importer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (_total > 0) ...[
                LinearProgressIndicator(
                    value: _total == 0 ? 0 : _completed / _total),
                const SizedBox(height: 10),
                Text('$_completed / $_total'),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isRunning ? null : _startImport,
                child: const Text('Import pericopes → Firestore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
