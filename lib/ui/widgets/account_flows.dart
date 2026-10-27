import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../services/device_reset.dart';
import '../../services/firebase_setup.dart';
import '../../state/auth_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/profile_provider.dart';
import '../../sync/bible_sync.dart';
import '../../theme/design_tokens.dart';
import 'action_scope.dart';

// Sign out, reset this device and delete account. Each one asks first,
// then closes the account menu ([menuContext]) and runs behind a progress
// dialog, and always ends on a real screen with a message saying what
// happened.

/// Signs out to a guest. Asks, on one sheet, whether this device keeps the
/// study data and the name.
Future<void> signOutFlow(BuildContext menuContext) async {
  final scope = ActionScope.of(menuContext);
  final c = scope.container;
  if (c.read(accountUserProvider).value == null) return;
  final name = c.read(displayNameProvider);

  final choice = await showModalBottomSheet<({bool keepData, bool keepName})>(
    context: menuContext,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SignOutSheet(name: name),
  );
  if (choice == null) return;
  if (menuContext.mounted) _closeMenu(menuContext);

  await scope.withProgress(scope.l10n.accountSigningOut, () async {
    final sync = c.read(syncControllerProvider.notifier);
    await sync.prepareSignOut(forget: !choice.keepData);
    await c.read(guestNameProvider.notifier).set(choice.keepName ? name : null);
    await c.read(authActionsProvider).signOut();
    if (!choice.keepData) await sync.clearLocalData();
  });
  final kept = choice.keepName ? name : null;
  scope.message(kept != null
      ? scope.l10n.accountSignedOutAs(kept)
      : scope.l10n.accountSignedOutGuest);
}

/// Erases this device's study data. Signed in, it also asks whether to
/// sign out or re-download, and offers deleting the cloud copy as a
/// separate switch (off by default, typed confirmation).
Future<void> resetDeviceFlow(BuildContext menuContext) async {
  final scope = ActionScope.of(menuContext);
  final c = scope.container;
  final user = c.read(accountUserProvider).value;

  final choice = await showModalBottomSheet<_ResetChoice>(
    context: menuContext,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ResetDeviceSheet(signedIn: user != null),
  );
  if (choice == null) return;
  if (choice.deleteCloud && !await _confirmTypedDelete(scope.navigator)) {
    return;
  }
  if (menuContext.mounted) _closeMenu(menuContext);

  try {
    await scope.withProgress(scope.l10n.accountResetting, () async {
      if (user == null) return wipeDeviceData(c);
      final sync = c.read(syncControllerProvider.notifier);
      // Upload pending edits first, so signing out loses nothing.
      if (choice.signOut && !choice.deleteCloud) {
        await sync.prepareSignOut(forget: true);
      }
      await sync.whilePaused(() async {
        if (choice.deleteCloud) {
          try {
            await deleteBibleCloudData(
                c.read(accountFirestoreProvider), user.uid);
          } catch (e) {
            throw _CloudDeleteFailed(e);
          }
        }
        if (choice.signOut) {
          await c
              .read(guestNameProvider.notifier)
              .set(c.read(displayNameProvider));
          await c.read(authActionsProvider).signOut();
        }
        await wipeDeviceData(c);
      });
      if (!choice.signOut) unawaited(sync.syncNow());
    });
  } on _CloudDeleteFailed catch (e) {
    reportNonFatal('delete cloud data', code: e.cause.runtimeType.toString());
    scope.message(scope.l10n.accountCloudDeleteFailed);
    return;
  }
  c.read(navProvider.notifier).setIndex(0);
  scope.message(scope.l10n.accountResetDeviceDone);
}

/// Permanently deletes the account (both apps) after a confirmation and
/// re-authentication.
Future<void> deleteAccountFlow(BuildContext menuContext) async {
  final scope = ActionScope.of(menuContext);
  final l10n = scope.l10n;
  final confirm = await showDialog<bool>(
    context: menuContext,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.accountDeleteAccountTitle),
      content: Text(l10n.accountDeleteAccountBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        _DangerButton(
          label: l10n.commonDelete,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  if (confirm != true) return;
  if (menuContext.mounted) _closeMenu(menuContext);

  try {
    await scope.withProgress(l10n.accountDeletingAccount,
        () => scope.container.read(authActionsProvider).deleteAccount());
  } on SignInCancelledException {
    return; // Dismissed re-authentication: nothing was deleted.
  } on SignInFailedException catch (e) {
    reportNonFatal('Re-authentication failed: ${e.failure.name}', code: e.code);
    scope.message(
        l10n.accountReauthFailed(SignInResult.failed(e.failure).message));
    return;
  } catch (e) {
    reportNonFatal('delete account', code: e.runtimeType.toString());
    scope.message(l10n.accountDeleteFailed);
    return;
  }
  scope.container.read(navProvider.notifier).setIndex(0);
  scope.message(l10n.accountDeleted);
}

class _CloudDeleteFailed implements Exception {
  final Object cause;
  _CloudDeleteFailed(this.cause);
}

/// Closes the account menu if it is still the top route.
void _closeMenu(BuildContext menuContext) {
  if (ModalRoute.of(menuContext)?.isCurrent ?? false) {
    Navigator.of(menuContext).pop();
  }
}

/// Type DELETE (in the app's language) to confirm removing cloud data.
Future<bool> _confirmTypedDelete(NavigatorState navigator) async {
  if (!navigator.mounted) return false;
  final ok = await showDialog<bool>(
    context: navigator.context,
    builder: (_) => const _TypedDeleteDialog(),
  );
  return ok ?? false;
}

class _TypedDeleteDialog extends StatefulWidget {
  const _TypedDeleteDialog();

  @override
  State<_TypedDeleteDialog> createState() => _TypedDeleteDialogState();
}

class _TypedDeleteDialogState extends State<_TypedDeleteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(String word) =>
      _controller.text.trim().toUpperCase() == word.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final word = l10n.accountDeleteCloudWord;
    return AlertDialog(
      title: Text(l10n.accountDeleteCloudTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountDeleteCloudBody(word)),
          const SizedBox(height: Space.md),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: word,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.commonCancel),
        ),
        _DangerButton(
          label: l10n.accountDeleteCloudAction,
          onPressed: _matches(word) ? () => Navigator.pop(context, true) : null,
        ),
      ],
    );
  }
}

/// Red filled button for the one destructive action in a dialog.
class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _DangerButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.error,
        foregroundColor: scheme.onError,
      ),
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onPressed!();
            },
      child: Text(label),
    );
  }
}

/// Shared frame for the account sheets: handle, title, body, buttons.
class _SheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget> actions;
  const _SheetFrame({
    required this.title,
    required this.children,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: Radii.sheet,
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.sm, Space.lg, Space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6, bottom: 14),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(Radii.xs),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Space.sm),
                ...children,
                const SizedBox(height: Space.lg),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: Space.md),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutSheet extends StatefulWidget {
  final String? name;
  const _SignOutSheet({required this.name});

  @override
  State<_SignOutSheet> createState() => _SignOutSheetState();
}

class _SignOutSheetState extends State<_SignOutSheet> {
  bool _keepData = true;
  bool _keepName = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = widget.name;
    return _SheetFrame(
      title: l10n.accountSignOutTitle,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context, (
              keepData: _keepData,
              keepName: name != null && _keepName,
            ));
          },
          child: Text(l10n.accountSignOut),
        ),
      ],
      children: [
        Text(
          l10n.accountSignOutSheetBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: Space.sm),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _keepData,
          onChanged: (v) => setState(() => _keepData = v ?? true),
          title: Text(l10n.accountKeepStudyData),
          subtitle: Text(l10n.accountKeepStudyDataSubtitle),
        ),
        if (name != null)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _keepName,
            onChanged: (v) => setState(() => _keepName = v ?? true),
            title: Text(l10n.accountKeepName),
            subtitle: Text(l10n.accountKeepNameSubtitle(name)),
          ),
      ],
    );
  }
}

class _ResetChoice {
  final bool signOut;
  final bool deleteCloud;
  const _ResetChoice({required this.signOut, required this.deleteCloud});
}

class _ResetDeviceSheet extends StatefulWidget {
  final bool signedIn;
  const _ResetDeviceSheet({required this.signedIn});

  @override
  State<_ResetDeviceSheet> createState() => _ResetDeviceSheetState();
}

class _ResetDeviceSheetState extends State<_ResetDeviceSheet> {
  bool _signOut = true;
  bool _deleteCloud = false;

  Widget _option(bool value, String title, String subtitle) {
    final selected = _signOut == value;
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _signOut = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    return _SheetFrame(
      title: l10n.accountResetDevice,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        _DangerButton(
          label: _deleteCloud
              ? l10n.accountResetAndDeleteCloud
              : l10n.accountResetDevice,
          onPressed: () => Navigator.pop(
            context,
            _ResetChoice(
              signOut: !widget.signedIn || _signOut,
              deleteCloud: widget.signedIn && _deleteCloud,
            ),
          ),
        ),
      ],
      children: [
        Text(l10n.accountResetErases,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: Space.xs),
        Text(l10n.accountResetEraseItems, style: quiet),
        const SizedBox(height: Space.sm),
        Text(l10n.accountResetStays, style: quiet),
        if (widget.signedIn) ...[
          const SizedBox(height: Space.sm),
          const Divider(),
          _option(true, l10n.accountResetSignOutOption,
              l10n.accountResetSignOutOptionSubtitle),
          _option(false, l10n.accountResetStayOption,
              l10n.accountResetStayOptionSubtitle),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _deleteCloud,
            onChanged: (v) => setState(() => _deleteCloud = v),
            title: Text(
              l10n.accountResetDeleteCloud,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: Text(l10n.accountResetDeleteCloudSubtitle),
          ),
        ],
      ],
    );
  }
}
