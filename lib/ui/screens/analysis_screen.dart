import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deep Dive',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revelation 14:1, 7',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Verse Analysis & Commentary',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '''Then I looked, and there before me was the Lamb, standing on Mount Zion, and with him 144,000 who had his name and his Father’s name written on their foreheads...

He said in a loud voice, "Fear God and give him glory, because the hour of his judgment has come. Worship him who made the heavens, the earth, the sea and the springs of water."''',
              style: GoogleFonts.gentiumBookPlus(
                textStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Historical Context',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This vision was written during a time of intense persecution under the Roman Empire (likely Domitian\'s reign). Mount Zion represents the heavenly sanctuary and the secure place of God\'s people, contrasting with the beast\'s domain described in chapter 13.',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Literary Analysis',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The "144,000" is heavily symbolic, drawing from military census imagery in the Old Testament (12 tribes x 12,000). The "Father\'s name written on their foreheads" directly parallels the High Priest\'s mitre in Exodus 28:36, marking them as wholly consecrated to God, in direct opposition to the "mark of the beast" (Rev 13:16).',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Application',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The first angel\'s message (verse 7) is a global imperative to "Fear God and give him glory." It reminds us that amidst the chaos of the world, ultimate allegiance belongs to the Creator. The call is deeply practical—worship is not merely intellectual, but a reorientation of life toward the One who made the heavens, earth, and sea.',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
