import 'package:flutter/material.dart';
import 'app_scale.dart';

class AppSpacing {
  final double xs, sm, md, lg, xl, xxl, xxxl, huge;
  final double screenPadding, groupedListInset, groupedSectionGap, minTapTarget;
  final double avatarSmall, avatarMedium, avatarLarge, avatarXLarge;
    final double cardGap;

  const AppSpacing._({
    required this.xs, required this.sm, required this.md, required this.lg,
    required this.xl, required this.xxl, required this.xxxl, required this.huge,
    required this.screenPadding, required this.groupedListInset,
    required this.groupedSectionGap, required this.minTapTarget,
    required this.avatarSmall, required this.avatarMedium,
    required this.avatarLarge, required this.avatarXLarge,
    required this.cardGap,
  });

  factory AppSpacing.of(BuildContext context) {
    final s = AppScale.factor(context);
    return AppSpacing._(
      xs: 4 * s, sm: 8 * s, md: 12 * s, lg: 16 * s,
      xl: 20 * s, xxl: 24 * s, xxxl: 32 * s, huge: 40 * s,
      screenPadding: 16 * s, groupedListInset: 16 * s, groupedSectionGap: 35 * s,
      minTapTarget: (44 * s).clamp(44, double.infinity),
      avatarSmall: 32 * s, avatarMedium: 40 * s, avatarLarge: 48 * s, avatarXLarge: 64 * s,
      cardGap: 12 * s,
    );
  }
}

class AppRadius {
  final double control, card, groupedSection, pill;

  const AppRadius._({required this.control, required this.card, required this.groupedSection, required this.pill});

  factory AppRadius.of(BuildContext context) {
    final s = AppScale.factor(context);
    return AppRadius._(control: 14 * s, card: 16 * s, groupedSection: 10 * s, pill: 999);
  }
}