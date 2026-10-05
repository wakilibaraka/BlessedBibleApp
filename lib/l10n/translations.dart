/// Per-locale translation tables.
///
/// Each map is keyed by the **English source string**; values are the
/// translated text. A missing key falls back to English automatically.
library;

import 'strings/strings_fr.dart';
import 'strings/strings_it.dart';
import 'strings/strings_pt.dart';
import 'strings/strings_ro.dart';
import 'strings/strings_es.dart';
import 'strings/strings_sw.dart';
import 'strings/strings_tl.dart';

const Map<String, Map<String, String>> kTranslations =
    <String, Map<String, String>>{
  'sw': swStrings,
  'tl': tlStrings,
  'ro': roStrings,
  'it': itStrings,
  'fr': frStrings,
  'es': esStrings,
  'pt': ptStrings,
};
