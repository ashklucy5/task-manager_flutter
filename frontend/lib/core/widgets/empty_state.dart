import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colors.labelTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.subhead(context,colors.labelSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}