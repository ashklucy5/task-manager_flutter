import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(child: CircularProgressIndicator(color: colors.brandPrimary));
  }
}