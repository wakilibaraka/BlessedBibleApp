// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final inputFilePath = 'assets/data/egw_genesis.txt';
  final outputFilePath = 'assets/data/egw_genesis.json';

  final file = File(inputFilePath);
  if (!file.existsSync()) {
    print('Input file not found at $inputFilePath');
    return;
  }

  final lines = file.readAsLinesSync();
  
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> result = {
    "Genesis": {}
  };
  
  String? currentChapter;
  String? currentVerse;
  String currentText = '';
  String? currentTitle;
  String? currentSource;

  void saveCurrentEntry() {
    if (currentChapter != null && currentVerse != null && currentText.isNotEmpty && currentTitle != null) {
      // Create chapter if not exists
      result["Genesis"]!.putIfAbsent(currentChapter, () => {});
      
      // Parse verses (might be a range like "1-3" or a list like "16, 17" or single "26")
      // To simplify, we will just associate the commentary with the first verse mentioned
      // or split by comma/hyphen. Let's just use the exact string as the key, or we can parse it.
      // The current UI might expect exact verse numbers.
      // Let's attach it to all mentioned verses.
      List<String> verses = [];
      if (currentVerse.contains('-')) {
         final parts = currentVerse.split('-');
         if (parts.length == 2) {
            int start = int.tryParse(parts[0].trim()) ?? 0;
            int end = int.tryParse(parts[1].trim()) ?? 0;
            if (start > 0 && end >= start) {
                for (int i = start; i <= end; i++) {
                    verses.add(i.toString());
                }
            } else {
               verses.add(currentVerse);
            }
         } else {
           verses.add(currentVerse);
         }
      } else if (currentVerse.contains(',')) {
         final parts = currentVerse.split(',');
         for (var part in parts) {
            verses.add(part.trim());
         }
      } else {
         verses.add(currentVerse.trim());
      }
      
      for (final v in verses) {
          result["Genesis"]![currentChapter]!.putIfAbsent(v, () => []);
          
          String fullText = currentText.trim();
          if (currentSource != null && currentSource!.isNotEmpty) {
             fullText += '\n\nSource: $currentSource';
          }
          
          result["Genesis"]![currentChapter]![v]!.add({
            "id": "egw_genesis_${currentChapter}_${v}_${DateTime.now().millisecondsSinceEpoch}",
            "title": currentTitle, // Combining author and title or just title
            "text": fullText,
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "updatedAt": DateTime.now().millisecondsSinceEpoch,
          });
      }
      
      // Reset for next entry
      currentText = '';
      currentTitle = null;
      currentSource = null;
    }
  }

  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('Genesis ')) {
      // Save previous entry if exists
      saveCurrentEntry();
      
      // Parse Genesis 1:1-3
      final refParts = line.substring(8).split(':');
      if (refParts.length == 2) {
        currentChapter = refParts[0].trim();
        currentVerse = refParts[1].trim();
      }
    } else if (line.startsWith('Title: ')) {
      currentTitle = line.substring(7).trim();
    } else if (line.startsWith('Source: ')) {
      currentSource = line.substring(8).trim();
      saveCurrentEntry(); // End of an entry
    } else {
      if (currentChapter != null && currentVerse != null) {
        currentText += '$line\n';
      }
    }
  }
  
  // Save the last entry
  saveCurrentEntry();

  final jsonOutput = jsonEncode(result);
  File(outputFilePath).writeAsStringSync(jsonOutput);
  print('Successfully parsed and saved to $outputFilePath');
}
