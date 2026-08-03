import 'package:flutter/material.dart';

class VerseCard extends StatelessWidget {
  final String reference;
  final String text;
  final Widget? bottomAction;

  const VerseCard({
    super.key,
    required this.reference,
    required this.text,
    this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade300),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reference,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
            if (bottomAction != null) ...[
              const SizedBox(height: 16),
              bottomAction!,
            ],
          ],
        ),
      ),
    );
  }
}
