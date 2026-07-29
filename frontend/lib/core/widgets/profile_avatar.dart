import 'package:flutter/material.dart';
import '../enums/user_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'status_dot.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final UserStatus status;
  final double? size; // null = use AppSpacing.avatarMedium
  final bool showStatusDot;

  const ProfileAvatar({
    super.key, required this.fullName, required this.status,
    this.avatarUrl, this.size, this.showStatusDot = true,
  });

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final effectiveSize = size ?? AppSpacing.of(context).avatarMedium;
    final ringColor = status.isLive ? colors.systemGreen : colors.separator;

    return SizedBox(
      width: effectiveSize + 8,
      height: effectiveSize + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: effectiveSize + 6,
            height: effectiveSize + 6,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ringColor, width: 2)),
          ),
          CircleAvatar(
            radius: effectiveSize / 2,
            backgroundColor: colors.fillQuaternary,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(_initials, style: TextStyle(color: colors.labelPrimary, fontSize: effectiveSize * 0.36, fontWeight: FontWeight.w600))
                : null,
          ),
          if (showStatusDot)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: colors.backgroundGrouped),
                child: StatusDot(status: status, size: 9),
              ),
            ),
        ],
      ),
    );
  }
}