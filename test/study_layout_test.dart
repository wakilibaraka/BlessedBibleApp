// Hub card sizes: v5 default view (Stories+Dictionary and VOTD+Streak
// pairs, Commentary full), the Large / Extra Large / Half picker
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

  test('v5 default view: order + half pairs', () async {
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
      'votd_archive',
      'streak',
    ]);
    final byId = {for (final c in layout) c.id: c};
    for (final id in [
      'your_space',
      'plans_live',
      'concordance',
      'commentary'
    ]) {
      expect(byId[id]!.span, CardSpan.full, reason: id);
      expect(byId[id]!.expanded, isFalse, reason: id);
    }
    for (final id in [
      'bible_stories',
      'dictionary',
      'votd_archive',
      'streak'
    ]) {
      expect(byId[id]!.span, CardSpan.half, reason: id);
    }
  });

  test('v4 stored layout migrates to the v5 default view', () async {
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
        'votd_archive',
        'streak',
      ])
        {'id': id, 'size': 'large', 'span': 'full', 'version': 4},
    ]));
    // NOTE: the v4->v5 reset rebuilds from the current defaults, so the
    // concordance card lands in canonical position (after Dictionary).
    // Layouts already stored at v5 instead get it appended at the end
    // via the missing-default backfill (no reset churn).
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
      'votd_archive',
      'streak',
    ]);
    final byId = {for (final c in layout) c.id: c};
    expect(byId['dictionary']!.span, CardSpan.half);
    expect(byId['streak']!.span, CardSpan.half);
    expect(byId['commentary']!.span, CardSpan.full);
    expect(byId['concordance']!.span, CardSpan.full);
  });

  test('v5 migration preserves user half customs', () async {
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
    // Untouched customs survive; everything else follows the default.
    expect(byId['commentary']!.span, CardSpan.half);
    expect(byId['dictionary']!.span, CardSpan.half);
  });

  test('v5 stored layout gains concordance at the end, customs kept', () async {
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
        'votd_archive',
        'streak',
      ])
        {
          'id': id,
          'size': 'large',
          'span': id == 'dictionary' ? 'half' : 'full',
          'version': 5,
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

  test('setCardSize persists span + expanded at version 5', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    container.read(studyLayoutProvider);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('dictionary', span: CardSpan.half, expanded: false);
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary', span: CardSpan.full, expanded: true);

    var layout = container.read(studyLayoutProvider);
    var byId = {for (final c in layout) c.id: c};
    expect(byId['dictionary']!.span, CardSpan.half);
    expect(byId['commentary']!.expanded, isTrue);

    // Quarter is rejected back to full.
    container
        .read(studyLayoutProvider.notifier)
        .setCardSize('commentary', span: CardSpan.quarter, expanded: false);
    layout = container.read(studyLayoutProvider);
    byId = {for (final c in layout) c.id: c};
    expect(byId['commentary']!.span, CardSpan.full);

    // Persisted JSON carries version 5.
    final prefs = container.read(preferencesProvider);
    final decoded = jsonDecode(prefs.getStudyLayout()!) as List;
    expect(decoded.every((e) => (e as Map)['version'] == 5), isTrue);
  });

  test('move swaps cards and persists the order', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    container.read(studyLayoutProvider);
    container.read(studyLayoutProvider.notifier).move('streak', 'votd_archive');

    var layout = container.read(studyLayoutProvider);
    var ids = [for (final c in layout) c.id];
    expect(ids.indexOf('streak'), ids.indexOf('votd_archive') - 1);

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
