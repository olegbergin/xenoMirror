import 'package:flutter/material.dart';
import 'package:client_app/core/theme/app_colors.dart';
import 'package:client_app/core/theme/app_text_styles.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Biometric progress bar with segmented design
///
/// Design Rules:
/// - 20 segments (discrete bars, NOT continuous LinearProgressIndicator)
/// - Attribute color fill (vitality green, mind cyan, soul magenta)
/// - Dimmed unfilled segments
/// - Optional glitch effect (future enhancement)
/// - Displays: Attribute label + XP value + Tier
///
/// Used for: Top bar attribute display (3 bars for Vitality, Mind, Soul)
class BiometricBar extends StatelessWidget {
  const BiometricBar({
    super.key,
    required this.label,
    required this.habitType,
    required this.currentXP,
    required this.tier,
    required this.progress,
  });

  final String label; // "VITALITY", "MIND", "SOUL"
  final HabitType habitType;
  final int currentXP;
  final int tier; // 0-3
  final double progress; // 0.0-1.0 progress within current tier

  static const int _totalSegments = 20;

  Color get _attributeColor {
    return AppColors.getAttributeColor(habitType.name);
  }

  @override
  Widget build(BuildContext context) {
    final filledSegments = (progress * _totalSegments).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Attribute label (ALL CAPS)
            Text(
              AppTextStyles.toUpperCase(label),
              style: AppTextStyles.headerSmall.copyWith(
                color: _attributeColor,
              ),
            ),
            // XP and Tier
            Text(
              '${currentXP} XP • TIER $tier',
              style: AppTextStyles.dataSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Segmented progress bar
        SizedBox(
          height: 8,
          child: Row(
            children: List.generate(_totalSegments, (index) {
              final isFilled = index < filledSegments;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? _attributeColor // Filled segments: full neon
                        : _attributeColor.withOpacity(0.15), // Empty: very dim
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
