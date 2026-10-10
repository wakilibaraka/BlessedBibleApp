import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/content_asset_guard.dart';
import '../../services/widget_update_service.dart';
import '../../state/content_gate_provider.dart';
import 'splash_loading_screen.dart';

/// Holds the app on the splash screen until Bible text, commentary, Word of
/// the Day and Verse of the Day are verified ([contentReadyProvider]).
///
/// On failure it shows a recovery screen instead of opening the app on
/// empty data. Once content has been ready, later provider refreshes never
/// send the user back to the splash (latched).
class ContentGate extends ConsumerStatefulWidget {
  final Widget child;
  const ContentGate({super.key, required this.child});

  @override
  ConsumerState<ContentGate> createState() => _ContentGateState();
}

class _ContentGateState extends ConsumerState<ContentGate> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    if (_ready) return _shell();

    final gate = ref.watch(contentReadyProvider);
    // Explicit checks (not .when) so a retry after an error shows the
    // splash again instead of the stale error.
    if (gate.isLoading) return const SplashLoadingScreen();
    if (gate.hasError) return ContentRecoveryScreen(error: gate.error!);
    _ready = true;
    return _shell();
  }

  /// Home-screen widget sync starts only once content is verified, so it
  /// never publishes placeholder data.
  Widget _shell() {
    ref.watch(widgetUpdateServiceProvider);
    return widget.child;
  }
}

/// Shown instead of the app when bundled content could not be prepared.
class ContentRecoveryScreen extends ConsumerStatefulWidget {
  final Object error;
  const ContentRecoveryScreen({super.key, required this.error});

  @override
  ConsumerState<ContentRecoveryScreen> createState() =>
      _ContentRecoveryScreenState();
}

class _ContentRecoveryScreenState extends ConsumerState<ContentRecoveryScreen> {
  bool _busy = false;

  Future<void> _retry({required bool repair}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await retryContentGate(ref, repair: repair);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuildProblem = widget.error is ContentAssetException;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 64, color: theme.primaryColor),
                const SizedBox(height: 24),
                Text(
                  'We couldn’t prepare your offline Bible',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  isBuildProblem
                      ? 'This copy of the app is missing its Bible content. '
                          'Please reinstall the app from the store.'
                      : 'Make sure your device has some free storage, then '
                          'try again. “Repair” reinstalls the Bible '
                          'text from the app; your notes and bookmarks are kept.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _busy ? null : () => _retry(repair: false),
                        child: const Text('Try again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy ? null : () => _retry(repair: true),
                        child: const Text('Repair'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SelectableText(
                  '${widget.error}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
