import 'package:flutter/material.dart';
import './app_colors.dart';
import './app_text_styles.dart';
import './app_scale.dart';

class AppTheme {
  AppTheme._();

  static const _textFamily = '.SF Pro Text';

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorSet colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brandPrimary,
      onPrimary: Colors.white,
      secondary: colors.systemBlue,
      onSecondary: Colors.white,
      error: colors.systemRed,
      onError: Colors.white,
      surface: colors.backgroundGrouped,
      onSurface: colors.labelPrimary,
      surfaceContainerHighest: colors.backgroundSecondary,
      outline: colors.separator,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.backgroundSecondary,
      canvasColor: colors.backgroundSecondary,
      // Reference-device text theme (scale factor 1.0). Actual on-device
      // scaling happens via MediaQuery.textScaler in main.dart's
      // MaterialApp.builder — see AppTheme.scaledBuilder below.
      textTheme: AppTypography.textTheme(colors),
      dividerColor: colors.separator,
      dividerTheme: DividerThemeData(
        color: colors.separator,
        thickness: 0.5,
        space: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundSecondary.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colors.labelPrimary,
        titleTextStyle: TextStyle(
          fontFamily: _textFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.labelPrimary,
        ),
        iconTheme: IconThemeData(color: colors.brandPrimary),
        actionsIconTheme: IconThemeData(color: colors.brandPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.backgroundGrouped.withValues(alpha: 0.94),
        selectedItemColor: colors.brandPrimary,
        unselectedItemColor: colors.systemGray,
        selectedLabelStyle: TextStyle(
          fontFamily: _textFamily,
          fontSize: 12,
          color: colors.brandPrimary,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _textFamily,
          fontSize: 12,
          color: colors.systemGray,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.brandPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.fillQuaternary,
          disabledForegroundColor: colors.labelTertiary,
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(
            fontFamily: _textFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: colors.brandPrimary.withValues(alpha: 0.15),
          foregroundColor: colors.brandPrimary,
          minimumSize: const Size.fromHeight(50),
          textStyle: TextStyle(
            fontFamily: _textFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.fillQuaternary,
        hintStyle: TextStyle(
          fontFamily: _textFamily,
          fontSize: 17,
          color: colors.labelTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.brandPrimary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.systemGreen
              : colors.systemGray.withValues(alpha: 0.4);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: colors.backgroundGrouped,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.separator, width: 0.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: colors.labelSecondary,
        textColor: colors.labelPrimary,
      ),
    );
  }

  /// Wraps [child] with a MediaQuery whose textScaler includes the
  /// device-size factor on top of the user's OS accessibility setting.
  /// Wire into MaterialApp's `builder` in main.dart:
  ///
  /// MaterialApp(
  ///   theme: AppTheme.light(),
  ///   darkTheme: AppTheme.dark(),
  ///   builder: (context, child) => AppTheme.scaledBuilder(context, child!),
  ///   ...
  /// )
  static Widget scaledBuilder(BuildContext context, Widget child) {
    final deviceScale = AppScale.factor(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(deviceScale).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.6),
      ),
      child: child,
    );
  }
}