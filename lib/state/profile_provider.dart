import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import 'auth_provider.dart';

/// Whether first-run setup is done. The app's home follows this, so
/// finishing or restarting onboarding never replaces the root route.
final onboardingCompleteProvider =
    NotifierProvider<OnboardingComplete, bool>(OnboardingComplete.new);

class OnboardingComplete extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).hasCompletedOnboarding();

  void set(bool value) {
    ref.read(preferencesProvider).setOnboardingComplete(value);
    state = value;
  }
}

/// The name this device shows while signed out (null: "Guest").
final guestNameProvider = NotifierProvider<GuestName, String?>(GuestName.new);

class GuestName extends Notifier<String?> {
  @override
  String? build() {
    final name = ref.read(preferencesProvider).getGuestDisplayName()?.trim();
    return (name?.isEmpty ?? true) ? null : name;
  }

  Future<void> set(String? name) async {
    await ref.read(preferencesProvider).setGuestDisplayName(name ?? '');
    state = ref.read(preferencesProvider).getGuestDisplayName();
  }
}

/// The name shown for whoever is using the app: the shared account's
/// profile name (also used by Blessed Arcade), then the sign-in name, then
/// the guest name. Null means a guest with no name.
final displayNameProvider = Provider<String?>((ref) {
  final user = ref.watch(accountUserProvider).value;
  if (user == null) return ref.watch(guestNameProvider);
  final profile = ref.watch(sharedProfileProvider).value?.displayName.trim();
  if (profile != null && profile.isNotEmpty) return profile;
  final auth = user.displayName?.trim();
  return (auth?.isEmpty ?? true) ? null : auth;
});
