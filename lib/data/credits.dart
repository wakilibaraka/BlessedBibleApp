import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';

/// Content credits shown on the Credits & sources screen. Keep in sync with
/// docs/LICENSES_REGISTER.md.
class CreditItem {
  final String title;
  final String detail;
  const CreditItem(this.title, this.detail);
}

class CreditSection {
  final String heading;
  final String? note;
  final List<CreditItem> items;
  const CreditSection(this.heading, this.items, {this.note});
}

/// The credits in the interface language. Section headings and generic
/// descriptions are translated; work titles, names and licence lines are
/// kept as published.
List<CreditSection> creditSections(AppLocalizations l10n) => [
      CreditSection(l10n.creditsScripture, [
        CreditItem('King James Version', l10n.creditsKjvDetail),
        CreditItem('Bible in Basic English (1965)', l10n.creditsPublicDomainUs),
        CreditItem('World English Bible', l10n.creditsPublicDomain),
        CreditItem(
            'Reina-Valera 1909, Louis Segond 1910, Luther 1912, Diodati 1885, '
            'Dutch 1917, Russian Synodal, Chinese Union Version, '
            'Arabic Van Dyck, Korean 1910, Ukrainian Kulish, '
            'Kralice Bible 1613 (Czech), Károli Bible (Hungarian)',
            l10n.creditsPublicDomain),
        CreditItem('Swahili and Tagalog Unlocked Literal Bible',
            'Licensed under CC BY-SA 4.0 (creativecommons.org/licenses/by-sa/4.0).'),
        CreditItem('Romanian BTF Bible (2015)',
            '© 2015 Dr. Brian J. Nibbe, Sr. All rights reserved.'),
        CreditItem('Hindi Indian Revised Version',
            'Licensed under CC BY-SA 4.0 (creativecommons.org/licenses/by-sa/4.0).'),
        CreditItem(
            'Updated Gdańsk Bible (Polish)',
            '© 2018 Fundacja Wrota Nadziei. Licensed under CC BY-ND 4.0 '
                '(creativecommons.org/licenses/by-nd/4.0).'),
        CreditItem('Bíblia Livre',
            'Licensed under Creative Commons Attribution (CC BY).'),
        CreditItem('Additional translations',
            l10n.creditsAdditionalTranslationsDetail),
      ]),
      CreditSection(
        l10n.creditsCommentary,
        [
          CreditItem(
              'Ellen G. White',
              'The Desire of Ages (1898), Patriarchs and Prophets (1890), '
                  'The Acts of the Apostles (1911), Prophets and Kings (1917).'),
          CreditItem('Uriah Smith', 'Daniel and the Revelation.'),
          CreditItem('E. J. Waggoner', 'Waggoner on Romans; The Glad Tidings.'),
          CreditItem('M. L. Andreasen', 'The Book of Hebrews (1948).'),
          CreditItem('Samuel T. Spear', l10n.creditsSelectedWriting),
          CreditItem(
              'Robert Jamieson, A. R. Fausset and David Brown',
              'Commentary Critical and Explanatory on the Whole Bible (1871). '
                  'Public domain. Source: CCEL (ccel.org/j/jamieson/jfb/cache/jfb.txt).'),
        ],
        note: l10n.creditsCommentaryPerspective,
      ),
      CreditSection(l10n.creditsStudyTools, [
        CreditItem(
            'Cross-references',
            'OpenBible.info (openbible.info/labs/cross-references), licensed '
                'under CC BY. Based on the Treasury of Scripture Knowledge.'),
        CreditItem(
            'Dictionary',
            'Easton\'s Bible Dictionary (1897) and Smith\'s Bible Dictionary '
                '(1863), public domain.'),
        CreditItem('Strong\'s lexicon',
            'James Strong\'s Hebrew and Greek dictionaries (1890), public domain.'),
        CreditItem(
            'Topical reading plans',
            'Nave\'s Topical Bible (1896) and Torrey\'s New Topical Textbook '
                '(1897), public domain; normalized via topical-bible-search (MIT).'),
      ]),
      CreditSection(l10n.creditsBibleStories, [
        CreditItem('Narrative summaries', l10n.creditsNarrativeDetail),
        CreditItem('Artwork',
            'Gustave Doré (1832–1883), public domain, via Wikimedia Commons.'),
      ]),
      CreditSection(l10n.creditsFonts, [
        CreditItem(
            'Alegreya, Bitter, Cardo, Cormorant Garamond, EB Garamond, '
            'Gentium Book Plus, IM FELL English, Inter, Lexend, Literata, '
            'Lora, Noto Serif, OpenDyslexic, Playfair Display, Source Sans 3',
            l10n.creditsFontsDetail(l10n.creditsLicenses)),
      ]),
    ];

/// Copyright lines from each bundled font's own metadata.
const Map<String, String> _fontCopyrights = {
  'Alegreya':
      'Copyright 2011 The Alegreya Project Authors (https://github.com/huertatipografica/Alegreya)',
  'Bitter':
      'Copyright 2011 The Bitter Project Authors (https://github.com/solmatas/BitterPro)',
  'Cardo': 'Copyright (c) 2002-2011, David J. Perry',
  'Cormorant Garamond':
      'Copyright 2015 The Cormorant Project Authors (github.com/CatharsisFonts/Cormorant)',
  'EB Garamond':
      'Copyright 2017 The EB Garamond Project Authors (https://github.com/octaviopardo/EBGaramond12)',
  'Gentium Book Plus': 'Copyright (c) 2003-2022 SIL International',
  'IM FELL English':
      '© 2007 Igino Marini (www.iginomarini.com) With Reserved Font Name IM FELL English Roman',
  'Inter':
      'Copyright 2016 The Inter Project Authors (https://github.com/rsms/inter)',
  'Lexend':
      'Copyright 2019 The Lexend Project Authors (https://github.com/googlefonts/lexend)',
  'Literata':
      'Copyright 2017 The Literata Project Authors (https://github.com/googlefonts/literata)',
  'Lora':
      'Copyright 2011 The Lora Project Authors (https://github.com/cyrealtype/Lora-Cyrillic), with Reserved Font Name "Lora".',
  'Noto Serif':
      'Copyright 2022 The Noto Project Authors (https://github.com/notofonts/latin-greek-cyrillic)',
  'OpenDyslexic':
      'Copyright (c) 2019-07-29, Abbie Gonzalez (https://abbiecod.es), with Reserved Font Name OpenDyslexic.',
  'Playfair Display':
      'Copyright 2017 The Playfair Display Project Authors (https://github.com/clauseggers/Playfair-Display), with Reserved Font Name "Playfair Display".',
  'Source Sans 3':
      '© 2023 Adobe (http://www.adobe.com/), with Reserved Font Name ‘Source’',
};

/// Adds the bundled fonts' OFL notices to Flutter's license page, next to
/// the pub package licenses Flutter collects automatically.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/licenses/OFL.txt');
    for (final entry in _fontCopyrights.entries) {
      yield LicenseEntryWithLineBreaks(
          ['${entry.key} (font)'], '${entry.value}\n\n$ofl');
    }
  });
}
