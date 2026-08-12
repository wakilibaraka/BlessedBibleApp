import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import 'textured_glass_container.dart';
import '../screens/your_space_screen.dart';
import '../../state/study_layout_provider.dart';

class YourSpaceHero extends StatelessWidget {
  final CardSize size;
  const YourSpaceHero({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const YourSpaceScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Space',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldAccent,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.primaryColor.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Highlights, Bookmarks & Notes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
