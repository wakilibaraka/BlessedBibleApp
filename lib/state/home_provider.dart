import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/home_data.dart';
import 'notes_provider.dart';

import '../state/commentary_provider.dart';

class HomeNotifier extends Notifier<HomeData> {
  static const votdList = [
    ['John 3:16', 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'],
    ['Psalm 23:1', 'The Lord is my shepherd; I shall not want.'],
    ['Proverbs 3:5', 'Trust in the Lord with all thine heart; and lean not unto thine own understanding.'],
    ['Romans 8:28', 'And we know that all things work together for good to them that love God, to them who are the called according to his purpose.'],
    ['Philippians 4:13', 'I can do all things through Christ which strengtheneth me.'],
    ['Isaiah 40:31', 'But they that wait upon the Lord shall renew their strength; they shall mount up with wings as eagles; they shall run, and not be weary; and they shall walk, and not faint.'],
    ['Jeremiah 29:11', 'For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil, to give you an expected end.'],
    ['Matthew 11:28', 'Come unto me, all ye that labour and are heavy laden, and I will give you rest.'],
    ['Psalm 46:10', 'Be still, and know that I am God: I will be exalted among the heathen, I will be exalted in the earth.'],
    ['Romans 12:2', 'And be not conformed to this world: but be ye transformed by the renewing of your mind, that ye may prove what is that good, and acceptable, and perfect, will of God.'],
    ['2 Timothy 1:7', 'For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.'],
    ['Hebrews 11:1', 'Now faith is the substance of things hoped for, the evidence of things not seen.'],
    ['Psalm 119:105', 'Thy word is a lamp unto my feet, and a light unto my path.'],
    ['Joshua 1:9', 'Have not I commanded thee? Be strong and of a good courage; be not afraid, neither be thou dismayed: for the Lord thy God is with thee whithersoever thou goest.'],
    ['Galatians 5:22', 'But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith,'],
    ['1 John 4:19', 'We love him, because he first loved us.'],
    ['Psalm 34:8', 'O taste and see that the Lord is good: blessed is the man that trusteth in him.'],
    ['Matthew 6:33', 'But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.'],
    ['Ephesians 2:8', 'For by grace are ye saved through faith; and that not of yourselves: it is the gift of God:'],
    ['1 Corinthians 13:4', 'Charity suffereth long, and is kind; charity envieth not; charity vaunteth not itself, is not puffed up,'],
    ['Psalm 27:1', 'The Lord is my light and my salvation; whom shall I fear? the Lord is the strength of my life; of whom shall I be afraid?'],
    ['Colossians 3:23', 'And whatsoever ye do, do it heartily, as to the Lord, and not unto men;'],
    ['Genesis 1:1', 'In the beginning God created the heaven and the earth.'],
    ['Psalm 91:1', 'He that dwelleth in the secret place of the most High shall abide under the shadow of the Almighty.'],
    ['Revelation 21:4', 'And God shall wipe away all tears from their eyes; and there shall be no more death, neither sorrow, nor crying, neither shall there be any more pain: for the former things are passed away.'],
    ['Lamentations 3:22', 'It is of the Lord\'s mercies that we are not consumed, because his compassions fail not.'],
    ['Isaiah 41:10', 'Fear thou not; for I am with thee: be not dismayed; for I am thy God: I will strengthen thee; yea, I will help thee; yea, I will uphold thee with the right hand of my righteousness.'],
    ['Psalm 37:4', 'Delight thyself also in the Lord; and he shall give thee the desires of thine heart.'],
    ['Matthew 5:16', 'Let your light so shine before men, that they may see your good works, and glorify your Father which is in heaven.'],
    ['2 Corinthians 5:17', 'Therefore if any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new.'],
    ['Psalm 139:14', 'I will praise thee; for I am fearfully and wonderfully made: marvellous are thy works; and that my soul knoweth right well.'],
    // Additional Daniel/Revelation verses often having commentary
    ['Daniel 2:1', 'And in the second year of the reign of Nebuchadnezzar Nebuchadnezzar dreamed dreams, wherewith his spirit was troubled, and his sleep brake from him.'],
    ['Revelation 14:12', 'Here is the patience of the saints: here are they that keep the commandments of God, and the faith of Jesus.'],
  ];

  @override
  HomeData build() {
    final notes = ref.watch(notesProvider);
    ref.watch(commentaryProvider);
    return _fetchData(notes);
  }

  HomeData _fetchData(List<PersonalNote> notes) {
    final commentaryNotifier = ref.read(commentaryProvider.notifier);
    
    // Filter votdList to only verses that have commentary
    final availableVotds = votdList.where((entry) {
      final refStr = entry[0];
      final lastSpaceIdx = refStr.lastIndexOf(' ');
      if (lastSpaceIdx == -1) return false;
      final bookName = refStr.substring(0, lastSpaceIdx);
      final refParts = refStr.substring(lastSpaceIdx + 1).split(':');
      if (refParts.length < 2) return false;
      final chapter = int.tryParse(refParts[0]) ?? 1;
      final verseNum = int.tryParse(refParts[1]);
      return commentaryNotifier.hasCommentary(bookName, chapter, verseNum);
    }).toList();

    // Fallback if none have commentary
    final pool = availableVotds.isNotEmpty ? availableVotds : votdList;

    final dayIndex = DateTime.now().difference(DateTime(2026, 1, 1)).inDays % pool.length;
    final votdEntry = pool[dayIndex];
    final votd = VerseOfTheDay(votdEntry[0], votdEntry[1]);

    // Show the 3 most recent notes
    final recentNotes = notes.reversed.take(3).toList();

    return HomeData(
      verseOfTheDay: votd,
      activeStudy: null,
      quickLinks: ["John 3:16", "Psalm 23:1", "Hebrews 11:1"],
      recentNotes: recentNotes,
      mostReadVerses: [],
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
