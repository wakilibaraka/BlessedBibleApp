import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../services/backup_service.dart';
import '../../services/bible_database_service.dart';
import '../../services/translation_pack_store.dart';
import '../../state/auth_provider.dart';
import '../../state/journal_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/translation_provider.dart';
import '../../state/user_data_provider.dart'
    show bookmarkDataProvider, highlightsProvider;

/// Shared account avatar: photo → initial → person icon, themed.
/// Extracted from the account button so every surface matches.
class AccountAvatar extends ConsumerWidget {
  final double size;
  const AccountAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    Widget fallback;
    final name = user?.displayName?.trim() ?? '';
    if (name.isNotEmpty) {
      fallback = CircleAvatar(
        radius: size / 2,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.4,
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Guest: same filled-circle footprint as the signed-in initial,
      // so the header never shows a naked outline icon.
      fallback = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: size * 0.55,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (user?.photoURL != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            user!.photoURL!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback,
          ),
        ),
      );
    }
    return SizedBox(width: size, height: size, child: fallback);
  }
}

/// Opens the account menu bottom sheet (avatar menu): account header,
/// Account, Settings, Backup, Restore, Reset and Sign in/out rows.
void showAccountMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
        // Material ancestor so ListTile ink splashes paint above the
        // decorated sheet background (debug assertion otherwise).
        child: Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Consumer(
            builder: (ctx, ref, _) {
              // Scrollable so the menu never overflows short screens;
              // sizes to content on tall ones.
              return SingleChildScrollView(
                child: _AccountMenuBody(),
              );
            },
          ),
        ),
      );
    },
  );
}

class _AccountMenuBody extends ConsumerWidget {
  const _AccountMenuBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final name = user?.displayName?.trim() ?? '';
    final email = user?.email?.trim() ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 5,
            margin: const EdgeInsets.only(top: 6, bottom: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        // ── Header ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              const AccountAvatar(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Guest',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty
                          ? email
                          : 'Sign in to sync across devices',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _MenuTile(
          icon: Icons.person_outline_rounded,
          label: 'Account',
          onTap: () {
            Navigator.of(context).pop();
            _showAccountSheet(context);
          },
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
            ref.read(navProvider.notifier).setIndex(4);
          },
        ),
        _MenuTile(
          icon: Icons.upload_file_outlined,
          label: 'Back up data',
          subtitle: 'Export notes, highlights and settings',
          onTap: () {
            Navigator.of(context).pop();
            BackupService.exportData(context, ref);
          },
        ),
        _MenuTile(
          icon: Icons.download_outlined,
          label: 'Restore data',
          subtitle: 'Import from a backup file',
          onTap: () {
            Navigator.of(context).pop();
            _showRestoreDialog(context, ref);
          },
        ),
        if (user == null) ...[
          _MenuTile(
            icon: Icons.account_circle_outlined,
            label: 'Sign in with Google',
            onTap: () => _signIn(context, context, ref, google: true),
          ),
          _MenuTile(
            icon: Icons.apple,
            label: 'Sign in with Apple',
            onTap: () => _signIn(context, context, ref, google: false),
          ),
        ] else ...[
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            destructive: true,
            onTap: () async {
              await ref.read(authActionsProvider).signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
        _MenuTile(
          icon: Icons.delete_sweep_outlined,
          label: 'Reset app',
          subtitle: 'Erase all on-device data',
          destructive: true,
          onTap: () => _confirmReset(context, context, ref),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.destructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(
              color: destructive ? color : null, fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
      trailing: Icon(Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

/// Existing account sheet (sign in/out, delete account), shared with the
/// account button. See account_button.dart for the source of truth.
void _showAccountSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          final currentAuthState = ref.watch(authStateProvider);
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentAuthState.value != null ? 'Account' : 'Sign In',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (currentAuthState.value == null) ...[
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: const Text('Sign in with Google'),
                      onTap: () async {
                        final result = await ref
                            .read(authActionsProvider)
                            .signInWithGoogle();
                        if (context.mounted && result == SignInResult.failed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Sign in failed. Please try again.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        if (context.mounted && result == SignInResult.success) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.apple),
                      title: const Text('Sign in with Apple'),
                      onTap: () async {
                        final result = await ref
                            .read(authActionsProvider)
                            .signInWithApple();
                        if (context.mounted && result == SignInResult.failed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Sign in failed. Please try again.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        if (context.mounted && result == SignInResult.success) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ] else ...[
                    ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundImage: currentAuthState.value?.photoURL !=
                                null
                            ? NetworkImage(currentAuthState.value!.photoURL!)
                            : null,
                        child: currentAuthState.value?.photoURL == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      title: Text(
                          currentAuthState.value?.displayName ?? 'Signed In'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: const Text('Sign Out',
                          style: TextStyle(color: Colors.orange)),
                      onTap: () async {
                        await ref.read(authActionsProvider).signOut();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Delete Account',
                          style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Account?'),
                            content: const Text(
                                'This is permanent and irreversible.\n\n'
                                'The following will be completely removed:\n'
                                '• Your sign-in account\n'
                                '• Your cloud-synced custom plans\n'
                                '• All on-device study data (bookmarks, highlights, history)'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          try {
                            await ref.read(authActionsProvider).deleteAccount();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Account deleted successfully.')),
                              );
                            }
                          } on ReauthCancelledException catch (_) {
                            // Ignore cancellation silently
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to delete account: ${e.toString().replaceAll("Exception: ", "")}'),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _signIn(
  BuildContext sheetContext,
  BuildContext context,
  WidgetRef ref, {
  required bool google,
}) async {
  final result = google
      ? await ref.read(authActionsProvider).signInWithGoogle()
      : await ref.read(authActionsProvider).signInWithApple();
  if (!sheetContext.mounted) return;
  if (result == SignInResult.failed) {
    ScaffoldMessenger.of(sheetContext).showSnackBar(
      const SnackBar(
        content: Text('Sign in failed. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } else if (result == SignInResult.success) {
    Navigator.of(sheetContext).pop();
  }
}

/// Restore dialog: paste a backup JSON (same format as Settings).
void _showRestoreDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Restore from Backup'),
      content: TextField(
        controller: controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'Paste your backup JSON here...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            Navigator.of(ctx).pop();
            if (text.isNotEmpty) {
              BackupService.importData(context, ref, text);
            }
          },
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

/// Destructive confirmation, then wipe all on-device user data.
void _confirmReset(
    BuildContext sheetContext, BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reset app?'),
      content: const Text('This erases all on-device data:\n'
          '• Bookmarks, highlights, notes & journal\n'
          '• Reading plans, progress & custom plans\n'
          '• Downloaded translations & streaks\n\n'
          'Settings, theme and the offline Bible stay untouched. '
          'This cannot be undone — back up first if needed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            Navigator.of(sheetContext).pop();
            await _resetAppData(ref);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App data reset. Fresh start!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text('Reset',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
        ),
      ],
    ),
  );
}

/// Erases user data (bookmarks, plans, progress, translations, streaks)
/// while keeping settings, theme and bundled content intact.
Future<void> _resetAppData(WidgetRef ref) async {
  final prefsSvc = ref.read(preferencesProvider);
  await prefsSvc.clearAllUserData();

  final sp = await SharedPreferences.getInstance();
  await sp.remove('active_plan_ids');
  final customIds = sp.getStringList('custom_plan_ids') ?? [];
  for (final id in customIds) {
    await sp.remove('custom_plan_$id');
  }
  await sp.remove('custom_plan_ids');
  for (final key in sp
      .getKeys()
      .where((k) => k.startsWith('reading_plan_state_'))
      .toList()) {
    await sp.remove(key);
  }
  await sp.remove('deleted_packs');
  await sp.remove('study_layout');

  // Downloaded translations (bundled packs self-restore on next launch).
  try {
    final installed = await bibleDbService.getTranslations();
    for (final t in installed) {
      if (!TranslationPackStore.isCoreId(t.translationId)) {
        try {
          await bibleDbService.deleteTranslationPack(t.translationId);
        } catch (_) {}
      }
    }
  } catch (_) {}

  await prefsSvc.setActiveTranslation('kjv');
  await prefsSvc.setSecondaryTranslation(null);

  ref.invalidate(bookmarkDataProvider);
  ref.invalidate(highlightsProvider);
  ref.invalidate(notesProvider);
  ref.invalidate(journalProvider);
  ref.invalidate(streakProvider);
  ref.invalidate(activePlanIdsProvider);
  ref.invalidate(availableTranslationsProvider);
  ref.invalidate(activeTranslationProvider);
  ref.invalidate(secondaryTranslationProvider);
  ref.invalidate(readingPlanProvider);
}
