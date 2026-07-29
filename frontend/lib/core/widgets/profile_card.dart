import 'package:flutter/material.dart';
import '../enums/user_role.dart';
import '../enums/user_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'profile_avatar.dart';
import 'status_dot.dart';

/// Reusable person card — avatar (with Pulse Ring) + name + role/position
/// + status. Used in team_pulse_screen (grid), team_list_screen (list),
/// and anywhere else a person needs to be shown consistently.
class ProfileCard extends StatelessWidget {
  final String fullName;
  final String? position;
  final UserRole? role;
  final UserStatus status;
  final String? avatarUrl;
  final String? subtitle; // e.g. "Active 2m ago" or current task title
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.fullName,
    required this.status,
    this.position,
    this.role,
    this.avatarUrl,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(spacing.md + spacing.xs),
          child: Row(
            children: [
              ProfileAvatar(
                fullName: fullName,
                status: status,
                avatarUrl: avatarUrl,
                size: spacing.avatarMedium,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName,
                      style: AppTypography.headline(context, colors.labelPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (position != null || role != null) ...[
                      SizedBox(height: spacing.xs / 2),
                      Row(
                        children: [
                          if (role != null) ...[
                            _RoleTag(role: role!),
                            if (position != null) SizedBox(width: spacing.xs),
                          ],
                          if (position != null)
                            Expanded(
                              child: Text(
                                position!,
                                style: AppTypography.footnote(context, colors.labelSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (subtitle != null) ...[
                      SizedBox(height: spacing.xs / 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption1(context, colors.brandPrimary)
                            .copyWith(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.xs),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusDot(status: status, size: 8),
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    status.displayLabel,
                    style: AppTypography.caption2(context, colors.labelTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTag extends StatelessWidget {
  final UserRole role;
  const _RoleTag({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = _colorFor(colors, role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        role.displayLabel,
        style: AppTypography.caption2(context, Colors.white).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _colorFor(AppColorSet colors, UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return colors.labelPrimary; // navy/black — CEO stands apart
      case UserRole.admin:
        return colors.systemBlue; // HR
      case UserRole.member:
        return colors.systemGray; // Team
    }
  }
}