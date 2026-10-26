// Hub card sizes: v6 default view (all cards Full except wotd + votd_archive
// which are Halves side-by-side at the bottom; streak is Full before them).
// Tests cover default order, migration, custom preservation, version
// persistence, and Move up/down reorder.

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/study_layout_provider.dart';

void main() {
  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
  }

  test('v6 default view: order + span layout', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final layout = StudyLayoutNotifier.defaultLayoutV2();
    expect([
      for (final c in layout) c.id
    ], [
      'your_space',
      'plans_live',
      'bible_stories',
      'dictionary',
      'concordance',
      'commentary',
      'streak',
      'wotd',
      'votd_archive',
    ]);
    final byId = {for (final c in layout) c.id: c};
    // All non-history cards are full width.
    for (final id in [
      'your_space',
      'plans_live',
      'bible_stories',
      'dictionary',
      'concordance',
      'commentary',
      'streak',
    ]) {
      expect(byId[id]!.span, CardSpan.full, reason: id);
    }
    // wotd and votd_archive are halves side by side at the bottom.
    for (final id in ['wotd', 'votd_archive']) {
      expect(byId[id]!.span, CardSpan.half, reason: id);
    }
  });

  test('old stored layout migrates to the v6 default view', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = PreferencesService(prefs);
    // Store a v4 layout (all full, old order)
    svc.saveStudyLayout(jsonEncode([
      for (final id in [
        'your_space',
        'plans_live',
        'bible_stories',
        'dictionary',
        'commentary',
        'wotd',
        'votd_archive',
        'streak',
      ])
        {'id': id, 'size': 'large', 'span': 'full', 'version': 4},
    ]));
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(svc),
      ],
    );
    addTearDown(container.dispose);

    final layout = container.read(studyLayoutProvider);
    expect([
      for (final c in layout) c.id
    ], [
      'your_space',
      'plans_live',
      'bible_stories',
      'dictionary',
      'concordance',
      'commentary',
      'streak',
      'wotd',
      'votd_archive',
    ]);
    final byId = {for (final c in layout) c.id: c};
    expect(byId['wotd']!.span, CardSpan.half);
    expect(byId['votd_archive']!.span, CardSpan.half);
    expect(byId['streak']!.span, CardSpan.full);
    expect(byId['commentary']!.span, CardSpan.full);
    expect(byId['concordance']!.span, CardSpan.full);
  });

  test('migration preserves user half customs', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = PreferencesService(prefs);
    svc.saveStudyLayout(jsonEncode([
      {'id': 'commentary', 'size': 'half', 'span': 'half', 'version': 4},
      {'id': 'your_space', 'size': 'large', 'span': 'full', 'version': 4},
    ]));
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(svc),
      ],
    );
    addTearDown(container.dispose);

    final layout = container.read(studyLayoutProvider);
    final byId = {for (final c in layout) c.id: c};
    // User had commentary as half — preserved through migration.
    expect(byId['commentary']!.span, CardSpan.half);
    // wotd and votd_archive default to half.
    expect(byId['wotd']!.span, CardSpan.half);
    expect(byId['votd_archive']!.span, CardSpan.half);
  });

  test('v6 stored layout gains concordance at the end, customs kept', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final svc = PreferencesService(prefs);
    svc.saveStudyLayout(jsonEncode([
      for (final id in [
        'your_space',
        'plans_live',
        'bible_stories',
        'dictionary',
        'commentary',
        'streak',
        'wotd',
        'votd_archive',
      ])
        {
          'id': id,
          'size': 'large',
          'span': id == 'dictionary' ? 'half' : 'full',
          'version': 6,
        },
    ]));
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(svc),
      ],
    );
    addTearDown(container.dispose);

    final layout = container.read(studyLayoutProvider);
    final ids = [for (final c in layout) c.id];
    expect(ids.last, 'concordance');
    final byId = {for (final c in layout) c.id: c};
    expect(byId['dictionary']!.span, CardSpan.half);
    expect(byId['concordance']!.span, CardSpan.full);
  });

  test('setCardSize persists span at version 6', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    container.read(studyLayoutProvider);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('dictionary', span: CardSpan.half);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary', span: CardSpan.half);

    var layout = container.read(studyLayoutProvider);
    var byId = {for (final c in layout) c.id: c};
    expect(byId['dictionary']!.span, CardSpan.half);
    expect(byId['commentary']!.span, CardSpan.half);

    // Quarter is rejected back to full.
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary', span: CardSpan.quarter);
    layout = container.read(studyLayoutProvider);
    byId = {for (final c in layout) c.id: c};
    expect(byId['commentary']!.span, CardSpan.full);

    // Persisted JSON carries version 6.
    final prefs = container.read(preferencesProvider);
    final decoded = jsonDecode(prefs.getStudyLayout()!) as List;
    expect(decoded.every((e) => (e as Map)['version'] == 6), isTrue);
  });

  test('move swaps cards and persists the order', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    container.read(studyLayoutProvider);
    // In the new layout wotd and votd_archive are adjacent (both halves at end).
    container.read(studyLayoutProvider.notifier).move('votd_archive', 'wotd');

    var layout = container.read(studyLayoutProvider);
    var ids = [for (final c in layout) c.id];
    expect(ids.indexOf('votd_archive'), ids.indexOf('wotd') - 1);

    // Unknown ids are no-ops.
    container.read(studyLayoutProvider.notifier).move('your_space', 'nope');
    layout = container.read(studyLayoutProvider);
    ids = [for (final c in layout) c.id];
    expect(ids.first, 'your_space');

    // Order round-trips through storage.
    final prefs = container.read(preferencesProvider);
    final decoded = jsonDecode(prefs.getStudyLayout()!) as List;
    expect([for (final e in decoded) (e as Map)['id']], ids);
  });
}
