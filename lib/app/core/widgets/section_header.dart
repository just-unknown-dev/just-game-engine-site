import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Reusable section heading with the Major Mono Display font.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.displayMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: AppTextStyles.bodyLarge),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
