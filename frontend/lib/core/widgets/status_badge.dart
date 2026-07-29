import 'package:flutter/material.dart';
import '../enums/task_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = _colorFor(colors, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.displayLabel,
        style: AppTypography.caption1(context, color).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _colorFor(AppColorSet colors, TaskStatus status) {
    switch (status) {
      case TaskStatus.pending: return colors.systemGray;
      case TaskStatus.inProgress: return colors.systemOrange;
      case TaskStatus.completed: return colors.systemGreen;
      case TaskStatus.onHold: return colors.systemBlue;
      case TaskStatus.overdue: return colors.systemRed;
      case TaskStatus.cancelled: return colors.systemGray;
    }
  }
}