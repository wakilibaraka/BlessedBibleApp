import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';

/// Apple-standard context sheet rows for Your Space items.
///
/// One implementation shared by notes, highlights, bookmarks and journal
/// entries so every item behaves identically: 50pt rows, icon + label,
/// destructive actions last in the error colour, dismiss on tap-outside.
class ItemAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Renders in the error colour and is preceded by a hairline divider.
  final bool destructive;

  const ItemAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
  });
}

class ItemContextSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ItemAction> actions;

  const ItemContextSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.actions,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<ItemAction> actions,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemContextSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destructiveIndex =
        actions.indexWhere((a) => a.destructive).clamp(0, actions.length);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(
                height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
            // Actions
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: actions.length,
                itemBuilder: (context, i) {
                  final a = actions[i];
                  final color = a.destructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface;
                  return Column(
                    children: [
                      if (i == destructiveIndex && i > 0)
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                      // 50pt row: comfortably above the 44pt minimum.
                      InkWell(
                        onTap: a.onTap == null
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                Navigator.of(context).pop();
                                a.onTap!();
                              },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              Icon(a.icon, size: 20, color: color),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  a.label,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: color,
                                    fontWeight:
                                        a.destructive ? FontWeight.w600 : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Cancel
            Divider(
                height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    context.l10n.commonCancel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation used before destructive rows.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel ?? context.l10n.commonDelete,
            style: TextStyle(color: Theme.of(ctx).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
