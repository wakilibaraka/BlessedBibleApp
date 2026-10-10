/// Curated reading-plan catalog (data only).
///
/// Extracted from the retired PlansHubV2Screen so the plan list is shared
/// by the Plans Library, the Study hub card and the plan detail screen
/// without depending on any screen file.
class PlanMetadata {
  final String id;
  final String title;
  final String description;
  final String category;
  final String badge;
  final int durationDays;
  final String dailyCommitment;
  final bool isAvailable;

  /// Source attribution + license (topical plans). When present the plan
  /// detail screen offers an "About this plan" row.
  final String? attribution;
  final String? license;

  const PlanMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.badge,
    this.durationDays = 365,
    this.dailyCommitment = '~15 min/day',
    this.isAvailable = true,
    this.attribution,
    this.license,
  });
}

const List<PlanMetadata> availablePlans = [
  PlanMetadata(
    id: 'mccheyne_1yr',
    title: "M'Cheyne 1-Year Plan",
    description:
        "Robert Murray M'Cheyne's beloved classic: 4 daily readings spanning the OT once and NT & Psalms twice.",
    category: 'Classic / 1-Year',
    badge: '4 Passages/day',
    durationDays: 365,
    dailyCommitment: '~15-20 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'chronological_1yr',
    title: 'Chronological — Bible in a Year',
    description:
        'Read the Bible in the historical order that events actually occurred throughout biblical history.',
    category: 'Chronological',
    badge: 'Historical Order',
    durationDays: 365,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'horner_10_chapters',
    title: 'Ten Lists — 10 Chapters a Day',
    description:
        'Immerse deeply in Scripture with 10 chapters every day from 10 distinct biblical lists simultaneously.',
    category: 'Classic / 1-Year',
    badge: '10 Chapters/day',
    durationDays: 365,
    dailyCommitment: '~35-45 min/day',
    isAvailable: true,
    attribution: "Reading method inspired by Grant Horner's 10-list system.",
  ),
  PlanMetadata(
    id: 'esv_through_the_bible',
    title: 'Through The Bible in a Year',
    description:
        'A balanced daily reading program that journeys systematically through both the Old and New Testaments.',
    category: 'Whole Bible',
    badge: '2 Passages/day',
    durationDays: 365,
    dailyCommitment: '~10-12 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_everyday_in_word',
    title: 'Every Day In The Word',
    description:
        'Four readings each day: from the Old Testament, the New Testament, Psalms, and Proverbs.',
    category: 'Whole Bible',
    badge: '4 Passages/day',
    durationDays: 365,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_gospels_and_epistles',
    title: 'Gospels & Epistles',
    description:
        'Dedicated focus on Jesus Christ’s life, teaching, and the foundational letters of the apostles.',
    category: 'Gospels & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~5 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_psalms_and_wisdom',
    title: 'Psalms & Wisdom Literature',
    description:
        'Devotional immersion in the poetry, prayers, and wisdom of Psalms, Proverbs, Job, and Ecclesiastes.',
    category: 'Wisdom',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~5 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_pentateuch_and_history',
    title: 'Pentateuch & History of Israel',
    description:
        'From the dawn of Creation through the Law and the rise and fall of the kingdom of Israel.',
    category: 'OT & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~8 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_chronicles_and_prophets',
    title: 'Chronicles & The Prophets',
    description:
        'Journey through 1 & 2 Chronicles harmonized alongside the major and minor Hebrew prophets.',
    category: 'OT & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~8 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'heartlight_ot_nt',
    title: 'Heartlight Old & New Testament',
    description:
        'Harmonious parallel daily reading pairing Old Testament narrative with New Testament revelation.',
    category: 'Whole Bible',
    badge: '2 Passages/day',
    durationDays: 365,
    dailyCommitment: '~10 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'topical_prayer_21',
    title: 'A Life of Prayer — 21 Days',
    description:
        'Twenty-one days of Scripture on prayer: asking, intercession, patience and praise.',
    category: 'Topical',
    badge: '21 days',
    durationDays: 21,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
    attribution:
        "References from Nave's Topical Bible (1896) and Torrey's New Topical Textbook (1897), public domain; normalized via j86schroeder/topical-bible-search (MIT).",
    license: 'Public domain sources (US); plan arrangement original.',
  ),
  PlanMetadata(
    id: 'topical_faith_21',
    title: 'The Way of Faith — 21 Days',
    description:
        'Three weeks on trust, belief and faithfulness across the canon.',
    category: 'Topical',
    badge: '21 days',
    durationDays: 21,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
    attribution:
        "References from Nave's Topical Bible (1896) and Torrey's New Topical Textbook (1897), public domain; normalized via j86schroeder/topical-bible-search (MIT).",
    license: 'Public domain sources (US); plan arrangement original.',
  ),
  PlanMetadata(
    id: 'topical_praise_14',
    title: 'Songs of Praise — 14 Days',
    description: 'Two weeks of psalms and songs celebrating God.',
    category: 'Topical',
    badge: '14 days',
    durationDays: 14,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
    attribution:
        "References from Nave's Topical Bible (1896) and Torrey's New Topical Textbook (1897), public domain; normalized via j86schroeder/topical-bible-search (MIT).",
    license: 'Public domain sources (US); plan arrangement original.',
  ),
  PlanMetadata(
    id: 'topical_covenant_7',
    title: 'The Covenant Story — 7 Days',
    description:
        "One week tracing God's covenants from Noah to the new covenant.",
    category: 'Topical',
    badge: '7 days',
    durationDays: 7,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
    attribution:
        "References from Nave's Topical Bible (1896) and Torrey's New Topical Textbook (1897), public domain; normalized via j86schroeder/topical-bible-search (MIT).",
    license: 'Public domain sources (US); plan arrangement original.',
  ),
];
