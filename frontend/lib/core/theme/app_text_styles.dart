import 'package:flutter/material.dart';
import 'app_scale.dart';

/// SF Pro / iOS type scale — every method now takes [context] so font
/// sizes scale by device width via AppScale, on top of whatever the
/// user's OS Dynamic Type setting already applies automatically.
class AppTypography {
  AppTypography._();

  static const _displayFamily = '.SF Pro Display';
  static const _textFamily = '.SF Pro Text';

  static TextStyle largeTitle(BuildContext context, Color color) => TextStyle(
        fontFamily: _displayFamily,
        fontSize: AppScale.scale(context, 34),
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.1,
      );

  static TextStyle title1(BuildContext context, Color color) => TextStyle(
        fontFamily: _displayFamily,
        fontSize: AppScale.scale(context, 28),
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.15,
      );

  static TextStyle title2(BuildContext context, Color color) => TextStyle(
        fontFamily: _displayFamily,
        fontSize: AppScale.scale(context, 22),
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle title3(BuildContext context, Color color) => TextStyle(
        fontFamily: _displayFamily,
        fontSize: AppScale.scale(context, 20),
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle headline(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 17),
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle body(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 17),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  static TextStyle callout(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 16),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  static TextStyle subhead(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 15),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  static TextStyle footnote(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 13),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  static TextStyle caption1(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 12),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.25,
      );

  static TextStyle caption2(BuildContext context, Color color) => TextStyle(
        fontFamily: _textFamily,
        fontSize: AppScale.scale(context, 11),
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.2,
      );

  /// ThemeData's textTheme still needs static styles (built once, no
  /// context available inside AppTheme._build) — this stays fixed at
  /// reference scale. Real per-device scaling for text happens via
  /// MediaQuery.textScaler in AppTheme.scaledBuilder (main.dart), which
  /// composes on top of whatever ThemeData provides here.
  static TextTheme textTheme(dynamic colors) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: _displayFamily, fontSize: 34, fontWeight: FontWeight.w700, color: colors.labelPrimary),
      displayMedium: TextStyle(fontFamily: _displayFamily, fontSize: 28, fontWeight: FontWeight.w700, color: colors.labelPrimary),
      displaySmall: TextStyle(fontFamily: _displayFamily, fontSize: 22, fontWeight: FontWeight.w700, color: colors.labelPrimary),
      titleLarge: TextStyle(fontFamily: _displayFamily, fontSize: 20, fontWeight: FontWeight.w600, color: colors.labelPrimary),
      titleMedium: TextStyle(fontFamily: _textFamily, fontSize: 17, fontWeight: FontWeight.w600, color: colors.labelPrimary),
      bodyLarge: TextStyle(fontFamily: _textFamily, fontSize: 17, fontWeight: FontWeight.w400, color: colors.labelPrimary),
      bodyMedium: TextStyle(fontFamily: _textFamily, fontSize: 16, fontWeight: FontWeight.w400, color: colors.labelPrimary),
      bodySmall: TextStyle(fontFamily: _textFamily, fontSize: 15, fontWeight: FontWeight.w400, color: colors.labelSecondary),
      labelLarge: TextStyle(fontFamily: _textFamily, fontSize: 17, fontWeight: FontWeight.w600, color: colors.labelPrimary),
      labelMedium: TextStyle(fontFamily: _textFamily, fontSize: 13, fontWeight: FontWeight.w400, color: colors.labelSecondary),
      labelSmall: TextStyle(fontFamily: _textFamily, fontSize: 12, fontWeight: FontWeight.w400, color: colors.labelSecondary),
    );
  }
}