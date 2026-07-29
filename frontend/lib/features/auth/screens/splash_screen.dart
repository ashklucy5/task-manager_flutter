import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Purely visual — AuthController already checks the stored token on
/// app start (see auth_provider.dart's _checkStoredToken), and
/// app_router's redirect logic moves the user off this screen the
/// moment status resolves. This screen just needs to look good while
/// that resolves, which is usually well under a second.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text('NexusFlow', style: AppTypography.title1(context, colors.labelPrimary)),
            const SizedBox(height: 8),
            Text('Where teams flow together', style: AppTypography.body(context, colors.labelSecondary)),
            const SizedBox(height: 40),
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(
                backgroundColor: colors.fillQuaternary,
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}