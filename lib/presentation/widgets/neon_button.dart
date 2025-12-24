import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_app/core/theme/app_colors.dart';
import 'package:client_app/core/theme/app_text_styles.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Protocol Button widget with neon border and cyberpunk styling
///
/// Design Rules:
/// - Rectangular shape (sharp corners, NOT rounded Material buttons)
/// - Neon border matching attribute color
/// - Semi-transparent background
/// - ALL CAPS Orbitron text
/// - Haptic feedback on press (MANDATORY)
/// - Idle → Pressed state with glow effect
///
/// Used for: Main habit logging buttons (VITALITY, MIND, SOUL)
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.habitType,
    required this.onPressed,
    this.width,
    this.height = 56,
  });

  final String label;
  final HabitType habitType;
  final VoidCallback onPressed;
  final double? width;
  final double height;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  Color get _attributeColor {
    return AppColors.getAttributeColor(widget.habitType.name);
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.mediumImpact(); // Required haptic feedback
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed
              ? _attributeColor.withOpacity(0.2) // Brighter when pressed
              : AppColors.glassOverlay,
          border: Border.all(
            color: _isPressed
                ? _attributeColor // Full neon when pressed
                : _attributeColor.withOpacity(0.6), // Dimmed when idle
            width: _isPressed ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(4), // Sharp corners
          boxShadow: _isPressed
              ? [
                  // Neon glow effect when pressed
                  BoxShadow(
                    color: _attributeColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            AppTextStyles.toUpperCase(widget.label),
            style: AppTextStyles.button.copyWith(
              color: _isPressed
                  ? _attributeColor // Neon text when pressed
                  : AppColors.textPrimary, // White text when idle
            ),
          ),
        ),
      ),
    );
  }
}
