import 'package:flutter/material.dart';
import '../enums/task_priority.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = colors.forPriority(priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(
        priority.displayLabel.toUpperCase(),
        style: AppTypography.caption2(context, color).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}