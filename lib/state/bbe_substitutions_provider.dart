import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bbeSubstitutionsProvider = FutureProvider<Set<String>>((ref) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/data/bbe_web_substitutions.json');
    final List<dynamic> decoded = jsonDecode(jsonStr);
    final Set<String> subs = {};
    for (var item in decoded) {
      final b = item['book'];
      final c = item['chapter'];
      final v = item['verse'];
      subs.add('${b}_${c}_${v}');
    }
    return subs;
  } catch (e) {
    return <String>{};
  }
});
