import 'package:blessed_account/blessed_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../l10n/l10n.dart';
import '../../state/auth_provider.dart';
import '../../sync/bible_sync.dart';
import 'account_menu.dart';

/// Decides whether to offer "Welcome back, sign in to restore your data".
///
/// A reinstall loses the Firebase session, but Android Auto Backup can bring
/// back the app's preferences, so onboarding looks finished and the user lands
/// signed out. We offer sign-in once when this device remembers an account and
/// the user didn't sign out on purpose.
class RestorePrompt {
  RestorePrompt._();

  /// Set when the user signs out themselves; cleared by the next sign-in.
  static const signedOutKey = 'account_signed_out_by_user';

  /// Set when the user dismisses the prompt; cleared by the next sign-in.
  static const dismissedKey = 'account_restore_prompt_dismissed';

  static bool shouldShow(SharedPreferences prefs, AccountUser? user) =>
      user == null &&
      prefs.getString(SyncController.lastUidKey) != null &&
      !(prefs.getBool(signedOutKey) ?? false) &&
      !(prefs.getBool(dismissedKey) ?? false);
}

/// Shows the [RestorePrompt] dialog over [child] at most once per launch.
class RestorePromptHost extends ConsumerStatefulWidget {
  final Widget child;
  const RestorePromptHost({super.key, required this.child});

  @override
  ConsumerState<RestorePromptHost> createState() => _RestorePromptHostState();
}

class _RestorePromptHostState extends ConsumerState<RestorePromptHost> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    // The auth state may already be resolved by the time this mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (_checked || !mounted) return;
    final auth = ref.read(accountUserProvider);
    if (auth.isLoading) return; // The listener in build retries.
    _checked = true;
    final prefs = ref.read(preferencesProvider).prefs;
    if (!RestorePrompt.shouldShow(prefs, auth.value)) return;

    final signIn = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.welcomeBackTitle),
        content: Text(ctx.l10n.welcomeBackBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.onboardingNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.accountSignInGoogle),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (signIn == true) {
      await runSignIn(context, ref, google: true);
    } else {
      await prefs.setBool(RestorePrompt.dismissedKey, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(accountUserProvider, (_, __) => _maybePrompt());
    return widget.child;
  }
}
