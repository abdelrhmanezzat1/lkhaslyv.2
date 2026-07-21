import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_dimensions.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A class that provides the theme data for the application.
class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
      onError: AppColors.onPrimary,
    ),
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.onSurface,
      displayColor: AppColors.onSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.onSurface),
      titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
        color: AppColors.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceM,
        horizontal: AppDimensions.spaceM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurface.withValues(alpha: 0.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      disabledColor: AppColors.background,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceS,
        vertical: AppDimensions.spaceXS,
      ),
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      secondaryLabelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onPrimary,
      ),
      brightness: Brightness.dark,
    ),
  );

  static final ThemeData lightTheme = darkTheme.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onLightSurface,
      onError: AppColors.onPrimary,
    ),
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.onLightSurface,
      displayColor: AppColors.onLightSurface,
    ),
    appBarTheme: darkTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.lightSurface,
      iconTheme: const IconThemeData(color: AppColors.onLightSurface),
      titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
        color: AppColors.onLightSurface,
      ),
    ),
    inputDecorationTheme: darkTheme.inputDecorationTheme.copyWith(
      fillColor: Colors.grey.shade200,
      labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.onLightSurface.withValues(alpha: 0.6),
      ),
    ),
    cardTheme: darkTheme.cardTheme.copyWith(
      color: AppColors.lightSurface,
      elevation: 4,
      shadowColor: Colors.black12,
    ),
    chipTheme: darkTheme.chipTheme.copyWith(
      backgroundColor: Colors.grey.shade300,
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onLightSurface,
      ),
      secondaryLabelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onPrimary,
      ),
      brightness: Brightness.light,
    ),
  );
}
