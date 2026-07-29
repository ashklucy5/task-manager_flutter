import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.title3(context, colors.labelPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,                          // ← overrides the infinite-width default
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,  // ← removes the 48pt min-height padding too
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
            child: Text(actionLabel!, style: AppTypography.footnote(context, colors.brandPrimary)),
          ),
      ],
    );
  }
}