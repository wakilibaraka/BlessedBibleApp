/// Curated Biblical concordance terms with verified KJV occurrence counts,
/// key reference anchors, and concise contextual definitions.
class ConcordanceTerm {
  final String word;
  final String category;
  final int countKjv;
  final String keyVerse;
  final String definition;

  const ConcordanceTerm({
    required this.word,
    required this.category,
    required this.countKjv,
    required this.keyVerse,
    required this.definition,
  });
}

const List<ConcordanceTerm> kConcordanceTerms = [
  ConcordanceTerm(
    word: 'grace',
    category: 'Salvation',
    countKjv: 160,
    keyVerse: 'Ephesians 2:8',
    definition:
        'The unmerited favor, divine influence, and enabling power of God upon the human heart.',
  ),
  ConcordanceTerm(
    word: 'faith',
    category: 'Spiritual Life',
    countKjv: 338,
    keyVerse: 'Hebrews 11:1',
    definition:
        'The substance of things hoped for, the evidence of things not seen; trusting God completely.',
  ),
  ConcordanceTerm(
    word: 'love',
    category: 'Christian Walk',
    countKjv: 547,
    keyVerse: '1 John 4:8',
    definition:
        'Agape: selfless, sacrificial, and unconditional devotion mirroring the very nature of God.',
  ),
  ConcordanceTerm(
    word: 'peace',
    category: 'Christian Walk',
    countKjv: 420,
    keyVerse: 'John 14:27',
    definition:
        'Shalom: wholeness, tranquility, and reconciliation with God surpassing all understanding.',
  ),
  ConcordanceTerm(
    word: 'hope',
    category: 'Spiritual Life',
    countKjv: 133,
    keyVerse: 'Romans 15:13',
    definition:
        'A joyful, confident anchor of the soul rooted in God\'s promises and Christ\'s resurrection.',
  ),
  ConcordanceTerm(
    word: 'mercy',
    category: 'Salvation',
    countKjv: 262,
    keyVerse: 'Psalm 23:6',
    definition:
        'Compassion, lovingkindness, and divine forbearance extended to the undeserving.',
  ),
  ConcordanceTerm(
    word: 'salvation',
    category: 'Salvation',
    countKjv: 158,
    keyVerse: 'Romans 1:16',
    definition:
        'Deliverance from the power and penalty of sin into eternal communion with God.',
  ),
  ConcordanceTerm(
    word: 'righteousness',
    category: 'Christian Walk',
    countKjv: 307,
    keyVerse: 'Matthew 6:33',
    definition:
        'Moral integrity, justice, and the righteous standing imputed to believers in Christ.',
  ),
  ConcordanceTerm(
    word: 'holy',
    category: 'God & Spirit',
    countKjv: 549,
    keyVerse: '1 Peter 1:16',
    definition:
        'Set apart, sacred, morally spotless, and exalted in supreme majesty.',
  ),
  ConcordanceTerm(
    word: 'wisdom',
    category: 'Christian Walk',
    countKjv: 222,
    keyVerse: 'Proverbs 9:10',
    definition:
        'The reverent fear of the Lord; divine insight applied with understanding to life.',
  ),
  ConcordanceTerm(
    word: 'truth',
    category: 'God & Spirit',
    countKjv: 224,
    keyVerse: 'John 14:6',
    definition:
        'Divine reality, integrity, and the unchanging revelation embodied in Jesus Christ.',
  ),
  ConcordanceTerm(
    word: 'covenant',
    category: 'Salvation',
    countKjv: 280,
    keyVerse: 'Jeremiah 31:31',
    definition:
        'A sacred promise and binding agreement instituted by God with His people.',
  ),
  ConcordanceTerm(
    word: 'spirit',
    category: 'God & Spirit',
    countKjv: 523,
    keyVerse: 'Galatians 5:22',
    definition:
        'The Holy Spirit: Counselor, Comforter, and source of spiritual life and renewal.',
  ),
  ConcordanceTerm(
    word: 'heart',
    category: 'Spiritual Life',
    countKjv: 895,
    keyVerse: 'Proverbs 4:23',
    definition:
        'The inner sanctuary of thoughts, desires, affections, and moral choices.',
  ),
  ConcordanceTerm(
    word: 'prayer',
    category: 'Spiritual Life',
    countKjv: 131,
    keyVerse: 'Philippians 4:6',
    definition:
        'Direct, intimate communication, petition, and communion with the living God.',
  ),
  ConcordanceTerm(
    word: 'praise',
    category: 'Christian Walk',
    countKjv: 261,
    keyVerse: 'Psalm 150:6',
    definition:
        'Expressing adoration, gratitude, and wonder for God\'s greatness and mighty works.',
  ),
  ConcordanceTerm(
    word: 'glory',
    category: 'God & Spirit',
    countKjv: 376,
    keyVerse: 'Psalm 19:1',
    definition:
        'The visible presence, luminous honor, and transcendent majesty of God.',
  ),
  ConcordanceTerm(
    word: 'kingdom',
    category: 'God & Spirit',
    countKjv: 369,
    keyVerse: 'Matthew 6:10',
    definition:
        'The sovereign rule, reign, and heavenly government of God in Christ.',
  ),
  ConcordanceTerm(
    word: 'light',
    category: 'God & Spirit',
    countKjv: 414,
    keyVerse: '1 John 1:5',
    definition:
        'Purity, spiritual understanding, and the radiant nature of God expelling darkness.',
  ),
  ConcordanceTerm(
    word: 'joy',
    category: 'Christian Walk',
    countKjv: 201,
    keyVerse: 'Nehemiah 8:10',
    definition:
        'Deep, abiding gladness of heart rooted in God\'s presence and faithfulness.',
  ),
  ConcordanceTerm(
    word: 'forgive',
    category: 'Salvation',
    countKjv: 95,
    keyVerse: '1 John 1:9',
    definition:
        'The gracious cancellation of sin\'s debt and release from guilt through the cross.',
  ),
  ConcordanceTerm(
    word: 'eternal',
    category: 'Salvation',
    countKjv: 47,
    keyVerse: 'John 3:16',
    definition:
        'Without beginning or end; the unending quality of divine life given to believers.',
  ),
  ConcordanceTerm(
    word: 'resurrection',
    category: 'Salvation',
    countKjv: 40,
    keyVerse: 'John 11:25',
    definition:
        'Christ\'s bodily triumph over the grave, securing eternal life for all who believe.',
  ),
  ConcordanceTerm(
    word: 'cross',
    category: 'Salvation',
    countKjv: 29,
    keyVerse: '1 Corinthians 1:18',
    definition:
        'The focal point of God\'s redemptive love, where Jesus bore humanity\'s sin.',
  ),
  ConcordanceTerm(
    word: 'life',
    category: 'Spiritual Life',
    countKjv: 412,
    keyVerse: 'John 10:10',
    definition:
        'Abundant spiritual vitality and communion with God through Christ.',
  ),
  ConcordanceTerm(
    word: 'blood',
    category: 'Salvation',
    countKjv: 392,
    keyVerse: 'Hebrews 9:22',
    definition:
        'The atoning sacrifice of Christ, sealing the new covenant and cleansing sin.',
  ),
  ConcordanceTerm(
    word: 'commandment',
    category: 'Christian Walk',
    countKjv: 333,
    keyVerse: 'Exodus 20:1',
    definition:
        'The holy precepts, moral law, and statutes given by God for holy living.',
  ),
  ConcordanceTerm(
    word: 'sabbath',
    category: 'Christian Walk',
    countKjv: 147,
    keyVerse: 'Genesis 2:3',
    definition:
        'The holy seventh-day rest established at creation as a sign of sanctification.',
  ),
  ConcordanceTerm(
    word: 'heaven',
    category: 'God & Spirit',
    countKjv: 691,
    keyVerse: 'Revelation 21:1',
    definition:
        'The glorious dwelling place of God, angels, and the redeemed saints.',
  ),
  ConcordanceTerm(
    word: 'gospel',
    category: 'Salvation',
    countKjv: 98,
    keyVerse: 'Romans 1:16',
    definition:
        'The Good News of salvation, redemption, and victory through Jesus Christ.',
  ),
  ConcordanceTerm(
    word: 'redeem',
    category: 'Salvation',
    countKjv: 119,
    keyVerse: 'Titus 2:14',
    definition:
        'To liberate and buy back from bondage by paying the ultimate ransom price.',
  ),
  ConcordanceTerm(
    word: 'blessed',
    category: 'Spiritual Life',
    countKjv: 290,
    keyVerse: 'Matthew 5:3',
    definition:
        'Favored by God, endowed with divine peace, and experiencing inner joy.',
  ),
];
