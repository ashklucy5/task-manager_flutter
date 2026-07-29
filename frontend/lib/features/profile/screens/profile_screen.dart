import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Profile', style: AppTypography.title1(context, colors.labelPrimary))),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
        children: [
          Center(
            child: Column(
              children: [
                ProfileAvatar(fullName: user.fullName, status: user.status, avatarUrl: user.avatarUrl, size: 88),
                SizedBox(height: spacing.sm),
                Text(user.fullName, style: AppTypography.title2(context, colors.labelPrimary)),
                SizedBox(height: spacing.xs / 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: colors.labelPrimary, borderRadius: BorderRadius.circular(6)),
                  child: Text(user.role.displayLabel, style: AppTypography.caption1(context, colors.backgroundPrimary)),
                ),
                if (user.position != null) ...[
                  SizedBox(height: spacing.xs / 2),
                  Text(user.position!, style: AppTypography.footnote(context, colors.labelSecondary)),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider).logout();
              },
              style: OutlinedButton.styleFrom(foregroundColor: colors.systemRed),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}