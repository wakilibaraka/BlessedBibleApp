import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../services/backup_service.dart';
import '../../services/bible_database_service.dart';
import '../../services/firebase_setup.dart';
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
import '../../sync/bible_sync.dart';

/// Shared account avatar: photo → initial → person icon, themed.
/// Extracted from the account button so every surface matches.
class AccountAvatar extends ConsumerWidget {
  final double size;
  const AccountAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(accountUserProvider).value;
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

    if (user?.photoUrl != null) {
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
            user!.photoUrl!,
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
    final user = ref.watch(accountUserProvider).value;
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
                      name.isNotEmpty ? name : context.l10n.accountGuest,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty
                          ? email
                          : context.l10n.accountSignInToSync,
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
          label: context.l10n.accountAccount,
          onTap: () {
            Navigator.of(context).pop();
            _showAccountSheet(context);
          },
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          label: context.l10n.accountSettings,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
            ref.read(navProvider.notifier).setIndex(4);
          },
        ),
        _MenuTile(
          icon: Icons.upload_file_outlined,
          label: context.l10n.accountBackUp,
          subtitle: context.l10n.accountBackUpSubtitle,
          onTap: () {
            Navigator.of(context).pop();
            BackupService.exportData(context, ref);
          },
        ),
        _MenuTile(
          icon: Icons.download_outlined,
          label: context.l10n.accountRestore,
          subtitle: context.l10n.accountRestoreSubtitle,
          onTap: () {
            Navigator.of(context).pop();
            _showRestoreDialog(context, ref);
          },
        ),
        if (user == null) ...[
          _MenuTile(
            icon: Icons.account_circle_outlined,
            label: context.l10n.accountSignInGoogle,
            onTap: () => _signIn(context, ref, google: true),
          ),
          if (ref.watch(appleSignInAvailableProvider))
            _MenuTile(
              icon: Icons.apple,
              label: context.l10n.accountSignInApple,
              onTap: () => _signIn(context, ref, google: false),
            ),
        ] else ...[
          const _SyncTile(),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: context.l10n.accountSignOut,
            destructive: true,
            onTap: () => _signOut(context, ref),
          ),
        ],
        _MenuTile(
          icon: Icons.delete_sweep_outlined,
          label: context.l10n.accountResetApp,
          subtitle: context.l10n.accountResetAppSubtitle,
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

/// Account sheet: sign in, or the signed-in account with sign-out and
/// delete-account.
void _showAccountSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(accountUserProvider).value;
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
                      user != null
                          ? context.l10n.accountAccount
                          : context.l10n.accountSignIn,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (user == null) ...[
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(context.l10n.accountSignInGoogle),
                      onTap: () => _signIn(context, ref, google: true),
                    ),
                    if (ref.watch(appleSignInAvailableProvider))
                      ListTile(
                        leading: const Icon(Icons.apple),
                        title: Text(context.l10n.accountSignInApple),
                        onTap: () => _signIn(context, ref, google: false),
                      ),
                  ] else ...[
                    ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      title: Text(
                          user.displayName ?? context.l10n.accountSignedIn),
                      subtitle: user.email == null ? null : Text(user.email!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: Text(context.l10n.accountSignOut,
                          style: TextStyle(color: Colors.orange)),
                      onTap: () => _signOut(context, ref),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(context.l10n.accountDeleteAccount,
                          style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(context.l10n.accountDeleteAccountTitle),
                            content:
                                Text(context.l10n.accountDeleteAccountBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(context.l10n.commonCancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(context.l10n.commonDelete,
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
                                SnackBar(
                                    content: Text(context.l10n.accountDeleted)),
                              );
                            }
                          } on SignInCancelledException {
                            // The user dismissed re-authentication; nothing
                            // was deleted.
                          } on SignInFailedException catch (e) {
                            reportNonFatal(
                                'Re-authentication failed: ${e.failure.name}',
                                code: e.code);
                            if (!context.mounted) return;
                            _showError(
                                context,
                                context.l10n.accountReauthFailed(
                                    SignInResult.failed(e.failure).message));
                          } catch (e) {
                            if (!context.mounted) return;
                            _showError(
                                context, context.l10n.accountDeleteFailed);
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

/// Runs a sign-in from a sheet: closes it on success, explains a failure,
/// and stays quiet when the user cancels.
Future<void> _signIn(
  BuildContext sheetContext,
  WidgetRef ref, {
  required bool google,
}) async {
  final actions = ref.read(authActionsProvider);
  final result = google
      ? await actions.signInWithGoogle()
      : await actions.signInWithApple();
  if (!sheetContext.mounted) return;
  switch (result.status) {
    case SignInStatus.success:
      final sync = ref.read(syncControllerProvider.notifier);
      if (await sync.afterSignIn() == SyncPhase.needsAccountChoice &&
          sheetContext.mounted) {
        await _askAccountChoice(sheetContext, ref);
      }
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
    case SignInStatus.failed:
      reportNonFatal('Sign-in failed: ${result.failure?.name}',
          code: result.code);
      _showError(sheetContext, result.message);
    case SignInStatus.cancelled:
      break;
  }
}

/// Signing in to a different account than this device's data came from:
/// merge that data into the account, or clear the device and download.
Future<void> _askAccountChoice(BuildContext context, WidgetRef ref) async {
  final startFresh = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.accountOtherDataTitle),
      content: Text(context.l10n.accountOtherDataBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.accountStartFresh),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.l10n.accountMerge),
        ),
      ],
    ),
  );
  if (startFresh == null) return;
  await ref
      .read(syncControllerProvider.notifier)
      .resolveAccountChoice(startFresh: startFresh);
}

/// Asks whether to keep this device's data, uploads pending changes, then
/// signs out.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final remove = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.accountSignOutTitle),
      content: Text(context.l10n.accountSignOutBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.accountRemoveFromDevice),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.l10n.accountKeepOnDevice),
        ),
      ],
    ),
  );
  if (remove == null) return;
  final sync = ref.read(syncControllerProvider.notifier);
  await sync.prepareSignOut(forget: remove);
  await ref.read(authActionsProvider).signOut();
  if (remove) await sync.clearLocalData();
  if (context.mounted) Navigator.of(context).pop();
}

/// Sync status for the signed-in account; tap to sync now (or, after
/// signing in to a different account, to choose what to do).
class _SyncTile extends ConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncControllerProvider);
    final (icon, label, subtitle) = switch (status.phase) {
      SyncPhase.syncing => (
          Icons.sync_rounded,
          context.l10n.accountSyncing,
          null
        ),
      SyncPhase.error => (
          Icons.sync_problem_rounded,
          context.l10n.accountSyncFailed,
          context.l10n.accountTapToRetry
        ),
      SyncPhase.needsAccountChoice => (
          Icons.sync_problem_rounded,
          context.l10n.accountSyncPaused,
          context.l10n.accountSyncChoose
        ),
      _ => (
          Icons.cloud_done_outlined,
          context.l10n.accountSyncNow,
          syncedLabel(status.lastSyncedAt, DateTime.now(), context.l10n)
        ),
    };
    return _MenuTile(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: () {
        final sync = ref.read(syncControllerProvider.notifier);
        if (status.phase == SyncPhase.needsAccountChoice) {
          _askAccountChoice(context, ref);
        } else {
          sync.syncNow();
        }
      },
    );
  }
}

/// "Synced just now", "Synced 5 min ago", ...
@visibleForTesting
String syncedLabel(DateTime? at, DateTime now, [AppLocalizations? l10n]) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (at == null) return l.accountNotSyncedYet;
  final d = now.difference(at);
  if (d.inMinutes < 1) return l.accountSyncedJustNow;
  if (d.inMinutes < 60) return l.accountSyncedMinAgo(d.inMinutes);
  if (d.inHours < 24) return l.accountSyncedHoursAgo(d.inHours);
  return l.accountSyncedOn(at.day, at.month, at.year);
}

void _showError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
    ),
  );
}

/// Restore dialog: paste a backup JSON (same format as Settings).
void _showRestoreDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.accountRestoreTitle),
      content: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: context.l10n.accountRestoreHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            Navigator.of(ctx).pop();
            if (text.isNotEmpty) {
              BackupService.importData(context, ref, text);
            }
          },
          child: Text(context.l10n.accountRestoreAction),
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
      title: Text(context.l10n.accountResetTitle),
      content: Text(context.l10n.accountResetBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            Navigator.of(sheetContext).pop();
            await _resetAppData(ref);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.accountResetDone),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text(context.l10n.accountReset,
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
