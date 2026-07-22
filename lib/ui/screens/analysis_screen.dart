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
            const SizedBox(height: 32),
            Text(
              '''This passage introduces a powerful vision of ultimate victory and a universal call to worship. The Lamb standing on Mount Zion represents Christ's triumphant reign. The 144,000 symbolize the complete, redeemed people of God who remain faithful. 

The first angel's message (verse 7) is a global imperative to "Fear God and give him glory." It is a reminder that amidst the chaos of the world, ultimate allegiance belongs to the Creator. The call is deeply practical—worship is not merely an intellectual acknowledgment, but a reorientation of life toward the One who made the heavens, earth, and sea.

This is a placeholder for the extended deep-dive analysis view that the user can read without leaving the Study tab layout context.''',
              style: GoogleFonts.lora(
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
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
