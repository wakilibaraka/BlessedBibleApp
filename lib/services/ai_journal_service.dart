import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalReflectionResult {
  final List<String> emotions;
  final List<String> prayerPoints;
  final List<String> recommendedVerses;

  const JournalReflectionResult({
    required this.emotions,
    required this.prayerPoints,
    required this.recommendedVerses,
  });
}

class AiJournalService {
  static const Map<String, String> _keywords = {
    'anxious': 'anxiety', 'anxiety': 'anxiety', 'worried': 'anxiety', 'stress': 'anxiety',
    'afraid': 'fear', 'fear': 'fear', 'scared': 'fear', 'panic': 'fear',
    'sad': 'sadness', 'sadness': 'sadness', 'depressed': 'sadness', 'cry': 'sadness',
    'lonely': 'loneliness', 'alone': 'loneliness', 'isolated': 'loneliness',
    'angry': 'anger', 'anger': 'anger', 'frustrated': 'anger', 'mad': 'anger',
    'tempted': 'temptation', 'sin': 'temptation', 'addicted': 'temptation',
    'guilty': 'guilt', 'shame': 'guilt', 'regret': 'guilt',
    'hopeless': 'hopelessness', 'despair': 'hopelessness', 'worthless': 'hopelessness',
    'confused': 'confusion', 'lost': 'confusion', 'doubt': 'doubt',
    'tired': 'exhaustion', 'exhausted': 'exhaustion', 'burnout': 'exhaustion',
    'grateful': 'gratitude', 'thankful': 'gratitude', 'blessed': 'gratitude',
    'joy': 'joy', 'happy': 'joy', 'excited': 'joy',
  };

  static const Map<String, List<String>> _emotionVerses = {
    'anxiety': ['Philippians 4:6-7', '1 Peter 5:7', 'Matthew 6:34'],
    'fear': ['Isaiah 41:10', '2 Timothy 1:7', 'Psalm 56:3'],
    'sadness': ['Psalm 34:18', 'Matthew 5:4', 'Revelation 21:4'],
    'loneliness': ['Deuteronomy 31:6', 'Psalm 27:10', 'Isaiah 41:10'],
    'anger': ['James 1:19-20', 'Ephesians 4:26-27', 'Proverbs 15:1'],
    'temptation': ['1 Corinthians 10:13', 'James 1:12', 'Hebrews 4:15'],
    'guilt': ['1 John 1:9', 'Romans 8:1', 'Psalm 103:12'],
    'hopelessness': ['Jeremiah 29:11', 'Romans 15:13', 'Lamentations 3:21-24'],
    'confusion': ['Proverbs 3:5-6', 'James 1:5', 'Psalm 119:105'],
    'doubt': ['Mark 9:24', 'James 1:6', 'Proverbs 3:5'],
    'exhaustion': ['Matthew 11:28', 'Isaiah 40:31', 'Galatians 6:9'],
    'gratitude': ['1 Thessalonians 5:18', 'Psalm 136:1', 'Colossians 3:15'],
    'joy': ['Romans 15:13', 'Nehemiah 8:10', 'Psalm 16:11'],
    'peace': ['John 14:27', 'Isaiah 26:3', 'Numbers 6:24-26'],
  };

  Future<JournalReflectionResult> analyzeEntry(String text) async {
    final lower = text.toLowerCase();
    final found = <String>[];

    for (final entry in _keywords.entries) {
      if (lower.contains(entry.key) && !found.contains(entry.value)) {
        found.add(entry.value);
      }
    }
    
    if (found.isEmpty) found.add('peace');
    
    final primaryEmotion = found.first;
    final recommendedVerses = _emotionVerses[primaryEmotion] ?? _emotionVerses['peace']!;

    final prayerPoints = [
      'Lord, bring comfort and strength as I navigate feelings of $primaryEmotion today.',
      'Grant me the grace to reflect on scripture, especially ${recommendedVerses.first}.',
      'Guide my steps in hope and peace, trusting in Your faithful promises.',
    ];

    return JournalReflectionResult(
      emotions: found,
      prayerPoints: prayerPoints,
      recommendedVerses: recommendedVerses,
    );
  }
}

final aiJournalServiceProvider = Provider<AiJournalService>((ref) => AiJournalService());
