import 'package:flutter/material.dart';

/// Cipher_01 Color Palette - XenoMirror OS Design System
///
/// This cyberpunk/neon color scheme creates the "Containment Unit" aesthetic.
/// Colors should be used exactly as specified - no approximations.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ===== BACKGROUND COLORS =====

  /// Main application background - pure void black
  static const Color voidBlack = Color(0xFF050505);

  /// Secondary background for cards/panels - deep space dark blue-black
  static const Color deepSpace = Color(0xFF0B0E14);

  /// Glass overlay for panels with transparency (80% opacity)
  /// Use with BackdropFilter for blur effect
  static const Color glassOverlay = Color(0xCC0B0E14); // 0xCC = 204 = 0.8 * 255

  // ===== ATTRIBUTE COLORS (Primary Neon) =====

  /// Vitality attribute - Matrix terminal green
  /// Used for: Legs & Core body parts, vitality XP bars, vitality buttons
  static const Color vitality = Color(0xFF00FF41);

  /// Mind attribute - Sci-fi hologram cyan
  /// Used for: Head & Sensors body parts, mind XP bars, mind buttons
  static const Color mind = Color(0xFF00F3FF);

  /// Soul attribute - Synthwave neon magenta
  /// Used for: Arms & Aura body parts, soul XP bars, soul buttons
  static const Color soul = Color(0xFFBC13FE);

  // ===== TEXT COLORS =====

  /// Primary text color - off-white for high contrast readability
  static const Color textPrimary = Color(0xFFE0E0E0);

  /// Secondary text color - muted slate blue for labels and less important info
  static const Color textSecondary = Color(0xFF556870);

  // ===== SYSTEM COLORS =====

  /// Alert/Error/Warning color - red neon
  static const Color alert = Color(0xFFFF2A2A);

  /// Success feedback (not in spec, but useful for confirmations)
  /// Using vitality green as success indicator
  static const Color success = vitality;

  // ===== HELPER METHODS =====

  /// Get attribute color by HabitType
  /// Returns the neon color associated with a specific attribute
  static Color getAttributeColor(String attributeType) {
    switch (attributeType.toLowerCase()) {
      case 'vitality':
        return vitality;
      case 'mind':
        return mind;
      case 'soul':
        return soul;
      default:
        return textPrimary; // Fallback
    }
  }

  /// Get a dimmed version of attribute color for inactive states
  /// Reduces opacity to 40% for disabled/inactive UI elements
  static Color getAttributeColorDimmed(String attributeType) {
    return getAttributeColor(attributeType).withOpacity(0.4);
  }

  /// Get a glow color for shader effects
  /// Increases brightness for glow/emission effects
  static Color getAttributeColorGlow(String attributeType) {
    final base = getAttributeColor(attributeType);
    // Increase luminance for glow effect
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }
}
