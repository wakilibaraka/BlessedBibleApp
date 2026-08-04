import 'package:flutter/material.dart';
import 'textured_glass_container.dart';

class SettingsPillCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsPillCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
