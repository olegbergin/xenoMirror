import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_app/core/theme/app_colors.dart';
import 'package:client_app/core/theme/app_text_styles.dart';

/// XenoMirror OS Dark Theme
///
/// This theme enforces the "Containment Unit" aesthetic:
/// - Void black backgrounds
/// - Neon accent colors
/// - No standard Material components (custom widgets required)
/// - All interactions must have haptic feedback
class AppTheme {
  AppTheme._(); // Private constructor

  /// Main dark theme for XenoMirror OS
  static ThemeData get darkTheme {
    return ThemeData(
      // ===== BRIGHTNESS & COLOR SCHEME =====
      brightness: Brightness.dark,

      // Primary swatch - using vitality green as brand color
      primaryColor: AppColors.vitality,

      // Scaffold background - pure void black
      scaffoldBackgroundColor: AppColors.voidBlack,

      // Color scheme - defines semantic colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.vitality,
        secondary: AppColors.mind,
        tertiary: AppColors.soul,
        surface: AppColors.deepSpace,
        error: AppColors.alert,
        onPrimary: AppColors.voidBlack, // Text on vitality buttons
        onSecondary: AppColors.voidBlack, // Text on mind buttons
        onTertiary: AppColors.voidBlack, // Text on soul buttons
        onSurface: AppColors.textPrimary, // Text on panels
        onError: AppColors.textPrimary, // Text on error messages
      ),

      // ===== TYPOGRAPHY =====
      textTheme: const TextTheme(
        // Display styles (largest)
        displayLarge: AppTextStyles.headerLarge,
        displayMedium: AppTextStyles.headerMedium,
        displaySmall: AppTextStyles.headerSmall,

        // Headline styles
        headlineLarge: AppTextStyles.headerLarge,
        headlineMedium: AppTextStyles.headerMedium,
        headlineSmall: AppTextStyles.headerSmall,

        // Title styles
        titleLarge: AppTextStyles.dataLarge,
        titleMedium: AppTextStyles.headerMedium,
        titleSmall: AppTextStyles.headerSmall,

        // Body styles
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,

        // Label styles (for buttons)
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.button,
        labelSmall: AppTextStyles.dataSmall,
      ),

      // ===== APP BAR THEME =====
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Transparent for Unity background
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, // Light status bar icons
        titleTextStyle: AppTextStyles.headerMedium,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ===== CARD THEME =====
      cardTheme: const CardThemeData(
        color: AppColors.glassOverlay,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)), // Sharp corners for cyberpunk
          side: BorderSide(
            color: AppColors.textSecondary,
            width: 1,
          ),
        ),
      ),

      // ===== ICON THEME =====
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // ===== DIVIDER THEME =====
      dividerTheme: const DividerThemeData(
        color: AppColors.textSecondary,
        thickness: 1,
        space: 16,
      ),

      // ===== BOTTOM SHEET THEME =====
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.glassOverlay,
        modalBackgroundColor: AppColors.glassOverlay,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
      ),

      // ===== SNACKBAR THEME (System Logs) =====
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.deepSpace,
        contentTextStyle: AppTextStyles.systemLog,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(
            color: AppColors.vitality,
            width: 1,
          ),
        ),
      ),

      // ===== DIALOG THEME =====
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.deepSpace,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(
            color: AppColors.textSecondary,
            width: 1,
          ),
        ),
        titleTextStyle: AppTextStyles.headerMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ===== DISABLED STANDARD MATERIAL COMPONENTS =====
      // NOTE: These should NOT be used - custom widgets required
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepSpace,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.button,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(
              color: AppColors.textSecondary,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // ===== SYSTEM UI OVERLAY STYLES =====

  /// Configure system UI (status bar, navigation bar) for dark theme
  static void setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light icons
        statusBarBrightness: Brightness.dark, // Dark background
        systemNavigationBarColor: AppColors.voidBlack, // Bottom nav bar
        systemNavigationBarIconBrightness: Brightness.light, // Light icons
      ),
    );
  }

  /// Configure immersive mode (hide system bars for full-screen Unity view)
  static void setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // Hide all system UI
    );
  }

  /// Restore normal mode (show system bars)
  static void setNormalMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values, // Show all system UI
    );
  }
}
