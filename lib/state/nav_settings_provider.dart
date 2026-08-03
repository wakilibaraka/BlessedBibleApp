import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'read_selection_provider.dart';
import 'nav_provider.dart';
import 'immersive_mode_provider.dart';

final bottomNavVisibilityProvider = Provider<bool>((ref) {
  final currentIndex = ref.watch(navProvider);
  final isRead = currentIndex == 1;

  // On Home, Search, and Settings, the bottom nav is ALWAYS visible
  if (!isRead) return true;

  // 1. Verse Selection hides nav (mutually exclusive)
  final hasSelection = ref.watch(readSelectionProvider).isNotEmpty;
  if (hasSelection) return false;

  // 2. Manual Nav hidden mode (via FAB toggle)
  final isManualHidden = ref.watch(navHiddenProvider);
  if (isManualHidden) return false;

  // 3. Auto-hide by scroll direction
  final isScrollHidden = ref.watch(chromeHiddenProvider);
  if (isScrollHidden) return false;

  return true;
});
