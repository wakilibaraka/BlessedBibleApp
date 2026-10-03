import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import 'main_nav_screen.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Exact Sepia Palette Values derived from AppColors
    const Color sepiaBg = AppColors.warmGoldBackground; // 0xFFF4EAD5
    const Color sepiaSurface = AppColors.warmGoldSurface; // 0xFFEFE3C3
    const Color sepiaInk = AppColors.warmGoldTextPrimary; // 0xFF2C221E
    const Color sepiaMuted = AppColors.sepiaTextPrimary; // 0xFF4A3B32
    const Color sepiaAccent = AppColors.warmGoldAccent; // 0xFF9E6B00
    
    // Harmonized tile colors
    const Color amberGold = Color(0xFFD49A36);
    const Color terracotta = Color(0xFFB56553);
    const Color oliveSage = Color(0xFF7D8C61);
    const Color tileGlyph = Color(0xFFF9F4E8); // Cream

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sepiaBg,
                sepiaSurface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  
                  // Decorative Motif + Title Block
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle radiant/sunrise motif behind
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Icon(
                            Icons.wb_sunny_rounded,
                            size: 100,
                            color: sepiaAccent.withValues(alpha: 0.12),
                          ),
                        ),
                        Column(
                          children: [
                            const Text(
                              'The Blessed Bible',
                              style: TextStyle(
                                fontFamily: 'EB Garamond',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: sepiaInk,
                                height: 1.05,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Scripture, without distraction.',
                              style: TextStyle(
                                fontSize: 17,
                                color: sepiaMuted.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 56),
                  
                  // Feature List
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _FeatureRow(
                          icon: Icons.menu_book_rounded,
                          title: 'The Pure Word',
                          subtitle: 'Read the Scriptures without distraction. Customize fonts and translations as you read.',
                          tileColor: amberGold,
                          iconColor: tileGlyph,
                          titleColor: sepiaInk,
                          subtitleColor: sepiaMuted,
                        ),
                        const SizedBox(height: 26),
                        _FeatureRow(
                          icon: Icons.calendar_month_rounded,
                          title: 'Curated Plans',
                          subtitle: 'Follow chronological or custom reading plans built to keep you consistent.',
                          tileColor: terracotta,
                          iconColor: tileGlyph,
                          titleColor: sepiaInk,
                          subtitleColor: sepiaMuted,
                        ),
                        const SizedBox(height: 26),
                        _FeatureRow(
                          icon: Icons.lightbulb_rounded,
                          title: 'Deep Insights',
                          subtitle: 'Access integrated commentary, maps, and pericopes seamlessly as you study.',
                          tileColor: oliveSage,
                          iconColor: tileGlyph,
                          titleColor: sepiaInk,
                          subtitleColor: sepiaMuted,
                        ),
                      ],
                    ),
                  ),
                  
                  // CTA
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(preferencesProvider).setOnboardingComplete(true);
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MainNavScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: terracotta,
                        foregroundColor: tileGlyph,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tileColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tileColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'EB Garamond',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: subtitleColor.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
