import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/search_settings_provider.dart';
import 'classic_search_screen.dart';
import 'new_search_screen.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useClassicSearch = ref.watch(searchSettingsProvider.select((s) => s.useClassicSearch));
    
    if (useClassicSearch) {
      return const ClassicSearchScreen();
    } else {
      return const NewSearchScreen();
    }
  }
}
