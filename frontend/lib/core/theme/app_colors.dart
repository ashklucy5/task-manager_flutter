import 'package:flutter/material.dart';
import '../enums/task_priority.dart';
/// Color tokens from the NexusFlow AI design spec, §0.1.
///
/// Each token exposes a [light] and [dark] value. Use [AppColors.of]
/// with a BuildContext to resolve the correct one automatically, or
/// reach for `AppColors.light`/`AppColors.dark` directly when building
/// theme data.
class AppColorSet {
  final Color brandPrimary;
  final Color systemBlue;
  final Color systemGreen;
  final Color systemOrange;
  final Color systemRed;
  final Color systemGray;
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelTertiary;
  final Color fillQuaternary;
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundGrouped;
  final Color separator;

  const AppColorSet({
    required this.brandPrimary,
    required this.systemBlue,
    required this.systemGreen,
    required this.systemOrange,
    required this.systemRed,
    required this.systemGray,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.fillQuaternary,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundGrouped,
    required this.separator,
  });

  /// Status color mapping shared by Presence, Tasks, Notifications, Finance.
  Color statusColor(NexusStatus status) {
    switch (status) {
      case NexusStatus.online:
      case NexusStatus.completed:
      case NexusStatus.paid:
      case NexusStatus.lowPriority:
        return systemGreen;
      case NexusStatus.busy:
      case NexusStatus.inProgress:
      case NexusStatus.pending:
      case NexusStatus.mediumPriority:
        return systemOrange;
      case NexusStatus.overdue:
      case NexusStatus.failed:
      case NexusStatus.highPriority:
      case NexusStatus.destructive:
        return systemRed;
      case NexusStatus.offline:
        return systemGray;
    }
  }
  Color forPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return systemGray;
      case TaskPriority.medium:
        return systemOrange;
      case TaskPriority.high:
      case TaskPriority.urgent:
        return systemRed;
    }
  }
}
/// Statuses that drive [AppColorSet.statusColor]. Keep this list in sync
/// with the mapping table in the design spec (§0.1) whenever a new status
/// concept is added anywhere in the app.
enum NexusStatus {
  online,
  busy,
  offline,
  completed,
  inProgress,
  pending,
  overdue,
  failed,
  paid,
  lowPriority,
  mediumPriority,
  highPriority,
  destructive,
}

class AppColors {
  AppColors._();

  static const light = AppColorSet(
    brandPrimary: Color(0xFF0F766E),
    systemBlue: Color(0xFF007AFF),
    systemGreen: Color(0xFF34C759),
    systemOrange: Color(0xFFFF9500),
    systemRed: Color(0xFFFF3B30),
    systemGray: Color(0xFF8E8E93),
    labelPrimary: Color(0xFF000000),
    labelSecondary: Color(0x993C3C43), // #3C3C43 @ 60%
    labelTertiary: Color(0x4D3C3C43), // #3C3C43 @ 30%
    fillQuaternary: Color(0x1F767680), // #767680 @ 12%
    backgroundPrimary: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF2F2F7),
    backgroundGrouped: Color(0xFFFFFFFF),
    separator: Color(0x4A3C3C43), // #3C3C43 @ 29%
  );

  static const dark = AppColorSet(
    brandPrimary: Color(0xFF2DD4BF),
    systemBlue: Color(0xFF0A84FF),
    systemGreen: Color(0xFF30D158),
    systemOrange: Color(0xFFFF9F0A),
    systemRed: Color(0xFFFF453A),
    systemGray: Color(0xFF8E8E93),
    labelPrimary: Color(0xFFFFFFFF),
    labelSecondary: Color(0x99EBEBF5), // #EBEBF5 @ 60%
    labelTertiary: Color(0x4DEBEBF5), // #EBEBF5 @ 30%
    fillQuaternary: Color(0x2E767680), // #767680 @ 18%
    backgroundPrimary: Color(0xFF000000),
    backgroundSecondary: Color(0xFF1C1C1E),
    backgroundGrouped: Color(0xFF1C1C1E),
    separator: Color(0xA654545B), // #54545B @ 65%
  );

  /// Resolve the correct token set for the current [Brightness].
  static AppColorSet of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
    
  }
}