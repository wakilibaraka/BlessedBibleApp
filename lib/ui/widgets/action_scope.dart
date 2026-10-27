import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';

/// What an account action needs once its sheet has closed, captured while
/// the sheet is still open: the sheet's context and its `WidgetRef` are
/// gone by then, and using them is what left screens frozen or messages
/// unshown.
class ActionScope {
  final NavigatorState navigator;
  final ScaffoldMessengerState messenger;
  final ProviderContainer container;
  final AppLocalizations l10n;

  ActionScope.of(BuildContext context)
      : navigator = Navigator.of(context, rootNavigator: true),
        messenger = ScaffoldMessenger.of(context),
        container = ProviderScope.containerOf(context, listen: false),
        l10n = context.l10n;

  /// A short confirmation or error, shown on the app's own scaffold.
  void message(String text) {
    if (!messenger.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
  }

  /// Runs [task] behind a progress dialog that can't be dismissed, so a
  /// slow step never looks like a frozen or empty screen. The dialog
  /// closes when [task] finishes or throws.
  Future<T> withProgress<T>(String label, Future<T> Function() task) async {
    final route = DialogRoute<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
    unawaited(navigator.push(route));
    try {
      return await task();
    } finally {
      // Removes this dialog only, even if something opened above it.
      if (navigator.mounted && route.isActive) navigator.removeRoute(route);
    }
  }
}
