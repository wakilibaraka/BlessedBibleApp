import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/firebase_setup.dart';
import '../../theme/design_tokens.dart';

/// One loading / empty / error look for every screen, so the app reacts
/// the same way wherever data is slow, missing or broken.

/// Centered spinner with an optional caption.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: message ?? context.l10n.stateLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: Space.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.palette.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Icon, title, an optional line of help and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 48, color: context.palette.textFaint),
            ),
            const SizedBox(height: Space.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (message != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.palette.textMuted),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.xl),
              FilledButton(
                // Accent + onAccent: not every theme sets the tonal colours.
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: context.palette.onAccent,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly error with a retry button. The raw error is sent to crash
/// reporting rather than shown, since exception text means nothing to a
/// reader and can leak file paths.
class ErrorState extends StatefulWidget {
  const ErrorState({super.key, this.error, this.message, this.onRetry});

  final Object? error;

  /// What failed, in plain words. Defaults to a generic line.
  final String? message;
  final VoidCallback? onRetry;

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  @override
  void initState() {
    super.initState();
    // Only the type: exception text can carry personal data.
    final error = widget.error;
    if (error != null) {
      reportNonFatal('ui error state', code: error.runtimeType.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: context.l10n.stateErrorTitle,
      message: widget.message ?? context.l10n.stateErrorBody,
      actionLabel: widget.onRetry == null ? null : context.l10n.commonRetry,
      onAction: widget.onRetry,
    );
  }
}
