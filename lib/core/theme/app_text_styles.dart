import 'package:flutter/material.dart';
import 'package:client_app/core/theme/app_colors.dart';

/// XenoMirror OS Typography System
///
/// Design Rules:
/// - Headers/Labels/Data: Orbitron (monospace/tech font) - ALL CAPS
/// - Body/Feedback: Rajdhani (sans-serif) - for readability
///
/// Font Weights:
/// - Orbitron: Regular (400), Bold (700), Black (900)
/// - Rajdhani: Regular (400), Medium (500), SemiBold (600), Bold (700)
class AppTextStyles {
  AppTextStyles._(); // Private constructor

  // ===== ORBITRON STYLES (Headers, Labels, Data) =====

  /// Large header - for main screen titles
  /// Example: "XENOMIRROR OS" splash screen
  static const TextStyle headerLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 32,
    fontWeight: FontWeight.w900, // Black
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
    height: 1.2,
  );

  /// Medium header - for section titles
  /// Example: "BIOMETRIC STATUS", "PROTOCOL ACTIONS"
  static const TextStyle headerMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
    height: 1.3,
  );

  /// Small header - for subsection labels
  /// Example: "VITALITY", "MIND", "SOUL" on buttons
  static const TextStyle headerSmall = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
    height: 1.3,
  );

  /// Data display - for numeric values and stats
  /// Example: "1,234 XP", "TIER 2", "87%"
  static const TextStyle dataLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
    height: 1.2,
  );

  /// Small data - for inline stats
  /// Example: "+10 XP", "Tier 1"
  static const TextStyle dataSmall = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
    height: 1.3,
  );

  // ===== RAJDHANI STYLES (Body Text, Feedback) =====

  /// Body text large - for descriptions
  /// Example: Activity descriptions in Injection Panel
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body text medium - for standard content
  /// Example: List items, settings options
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  /// Body text small - for captions and hints
  /// Example: "Tap to log activity", timestamps
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  /// Button text - for Protocol Buttons
  /// Example: "INJECT VITALITY", "LOG HABIT"
  static const TextStyle button = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
    height: 1.0,
  );

  /// Toast/System log text - for feedback messages
  /// Example: "EVOLUTION DETECTED: LEGS → TIER 2"
  static const TextStyle systemLog = TextStyle(
    fontFamily: 'Rajdhani',
    fontSize: 13,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // ===== HELPER METHODS =====

  /// Apply attribute color to a text style
  /// Used for colored labels and values
  static TextStyle withAttributeColor(TextStyle base, String attributeType) {
    return base.copyWith(
      color: AppColors.getAttributeColor(attributeType),
    );
  }

  /// Convert text to ALL CAPS (for Orbitron styles)
  /// This ensures design spec compliance
  static String toUpperCase(String text) {
    return text.toUpperCase();
  }

  /// Apply glow effect to text style for emphasis
  /// Used for active states and highlights
  static TextStyle withGlow(TextStyle base, Color glowColor) {
    return base.copyWith(
      shadows: [
        Shadow(
          color: glowColor.withOpacity(0.6),
          blurRadius: 8,
        ),
        Shadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 16,
        ),
      ],
    );
  }
}
