import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/backup_service.dart';
import '../../services/firebase_setup.dart';
import '../../state/auth_provider.dart';
import '../../state/profile_provider.dart';
import '../../state/nav_provider.dart';
import '../../sync/bible_sync.dart';
import '../../theme/design_tokens.dart';
import 'account_flows.dart';
import 'action_scope.dart';

/// Shared account avatar: photo → initial → person icon, themed.
/// Extracted from the account button so every surface matches.
class AccountAvatar extends ConsumerWidget {
  final double size;
  const AccountAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(accountUserProvider).value;
    final name = ref.watch(displayNameProvider) ?? '';
    Widget fallback;
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
          borderRadius: Radii.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
        // Material ancestor so ListTile ink splashes paint above the
        // decorated sheet background (debug assertion otherwise).
        child: Material(
          color: Colors.transparent,
          borderRadius: Radii.sheet,
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
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
          ),
        ),
        // ── Unified Hero Account Card ──────────────
        const _AccountHeroCard(),
        const Divider(height: 1, indent: 16, endIndent: 16),
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
          // The menu stays open until the share sheet is up: the export
          // needs this context, which closing the menu first would end.
          onTap: () async {
            await BackupService.exportData(context, ref);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        _MenuTile(
          icon: Icons.download_outlined,
          label: context.l10n.accountRestore,
          subtitle: context.l10n.accountRestoreSubtitle,
          onTap: () => _showRestoreDialog(context, ref),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _MenuTile(
          icon: Icons.delete_sweep_outlined,
          label: context.l10n.accountResetDevice,
          subtitle: context.l10n.accountResetDeviceSubtitle,
          destructive: true,
          onTap: () => resetDeviceFlow(context),
        ),
      ],
    );
  }
}

class _AccountHeroCard extends ConsumerStatefulWidget {
  const _AccountHeroCard();

  @override
  ConsumerState<_AccountHeroCard> createState() => _AccountHeroCardState();
}

class _AccountHeroCardState extends ConsumerState<_AccountHeroCard> {
  bool _isSigningIn = false;

  Future<void> _handleSignIn({required bool google}) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      final success = await runSignIn(context, ref, google: google);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(accountUserProvider).value;
    final chosenName = ref.watch(displayNameProvider);
    final name = chosenName ?? context.l10n.accountGuest;
    final email = user?.email?.trim() ?? '';
    final appleAvailable = ref.watch(appleSignInAvailableProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.accountAccount.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showEditDisplayNameDialog(context, ref),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        chosenName == null
                            ? context.l10n.accountAddName
                            : context.l10n.accountEditName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const AccountAvatar(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                            theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (user == null) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: _isSigningIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.account_circle_outlined, size: 20),
                label: Text(context.l10n.accountSignInGoogle),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.lg),
                  ),
                ),
                onPressed:
                    _isSigningIn ? null : () => _handleSignIn(google: true),
              ),
            ),
            if (appleAvailable) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.apple, size: 20),
                  label: Text(context.l10n.accountSignInApple),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.lg),
                    ),
                  ),
                  onPressed:
                      _isSigningIn ? null : () => _handleSignIn(google: false),
                ),
              ),
            ],
          ] else ...[
            const _SyncSection(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(context.l10n.accountSignOut),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.lg),
                      ),
                    ),
                    onPressed: () => signOutFlow(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: context.l10n.accountDeleteAccount,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: theme.colorScheme.error.withValues(alpha: 0.7)),
                  onPressed: () => deleteAccountFlow(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

void _showEditDisplayNameDialog(BuildContext context, WidgetRef ref) {
  final signedIn = ref.read(accountUserProvider).value != null;
  final scope = ActionScope.of(context);
  final controller =
      TextEditingController(text: ref.read(displayNameProvider) ?? '');

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(signedIn
          ? context.l10n.accountEditName
          : context.l10n.accountChooseName),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: 30,
        decoration: InputDecoration(
          hintText: context.l10n.accountNameHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            final newName = controller.text.trim();
            Navigator.of(ctx).pop();
            try {
              await scope.container
                  .read(authActionsProvider)
                  .updateDisplayName(newName);
              scope.message(scope.l10n.accountNameUpdated);
            } catch (e) {
              reportNonFatal('update display name',
                  code: e.runtimeType.toString());
              scope.message(scope.l10n.accountNameSaveFailed);
            }
          },
          child: Text(context.l10n.accountSave),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
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

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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

    return InkWell(
      borderRadius: BorderRadius.circular(Radii.lg),
      onTap: () {
        HapticFeedback.selectionClick();
        final sync = ref.read(syncControllerProvider.notifier);
        if (status.phase == SyncPhase.needsAccountChoice) {
          _askAccountChoice(context, ref);
        } else {
          sync.syncNow();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            status.phase == SyncPhase.syncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  )
                : Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

/// Signs in, settles which data wins if this device held another account's
/// data, and explains failures. Returns true when signed in.
Future<bool> runSignIn(
  BuildContext context,
  WidgetRef ref, {
  required bool google,
}) async {
  final actions = ref.read(authActionsProvider);
  final result = google
      ? await actions.signInWithGoogle()
      : await actions.signInWithApple();
  if (!context.mounted) return false;
  switch (result.status) {
    case SignInStatus.success:
      final sync = ref.read(syncControllerProvider.notifier);
      if (await sync.afterSignIn() == SyncPhase.needsAccountChoice &&
          context.mounted) {
        await _askAccountChoice(context, ref);
      }
      return true;
    case SignInStatus.failed:
      reportNonFatal('Sign-in failed: ${result.failure?.name}',
          code: result.code);
      _showError(context, result.message);
      return false;
    case SignInStatus.cancelled:
      return false;
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
          child: Text(context.l10n.accountStartFresh,
              style: TextStyle(color: ctx.palette.danger)),
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
          onPressed: () async {
            final text = controller.text.trim();
            Navigator.of(ctx).pop();
            // Import while the menu is still open (it needs this context),
            // then close the menu so the result message shows.
            if (text.isNotEmpty) {
              await BackupService.importData(context, ref, text);
            }
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(context.l10n.accountRestoreAction),
        ),
      ],
    ),
  );
}
