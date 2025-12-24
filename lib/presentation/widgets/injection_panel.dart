import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_app/core/theme/app_colors.dart';
import 'package:client_app/core/theme/app_text_styles.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Injection Panel - Modal bottom sheet for activity selection
///
/// Design Rules:
/// - Modal Bottom Sheet (NOT full-screen page)
/// - Glass overlay with BackdropFilter blur effect
/// - Rounded top corners (16px radius)
/// - Neon border matching attribute color
/// - List of activities with XP values
/// - Haptic feedback on selection (MANDATORY)
///
/// Used for: Activity selection after tapping a Protocol Button
class InjectionPanel {
  /// Show injection panel for a specific habit type
  ///
  /// Returns selected activity and XP amount, or null if canceled.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required HabitType habitType,
  }) async {
    final attributeColor = AppColors.getAttributeColor(habitType.name);
    final activities = _getActivitiesForType(habitType);

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent, // Transparent to show backdrop filter
      isScrollControlled: true,
      builder: (context) => _InjectionPanelContent(
        habitType: habitType,
        attributeColor: attributeColor,
        activities: activities,
      ),
    );
  }

  /// Get activity list for a specific habit type
  static List<_ActivityOption> _getActivitiesForType(HabitType habitType) {
    switch (habitType) {
      case HabitType.vitality:
        return [
          _ActivityOption('Squats (10 reps)', 'squats', 10),
          _ActivityOption('Push-ups (10 reps)', 'pushups', 12),
          _ActivityOption('Running (10 min)', 'running', 20),
          _ActivityOption('Walking (15 min)', 'walking', 15),
          _ActivityOption('Sleep (8 hrs)', 'sleep', 15),
          _ActivityOption('Workout Session', 'workout', 25),
        ];
      case HabitType.mind:
        return [
          _ActivityOption('Reading (15 min)', 'reading', 15),
          _ActivityOption('Study Session (15 min)', 'study', 12),
          _ActivityOption('Planning', 'planning', 10),
          _ActivityOption('Learning Course', 'learning', 18),
          _ActivityOption('Writing (15 min)', 'writing', 14),
        ];
      case HabitType.soul:
        return [
          _ActivityOption('Meditation (10 min)', 'meditation', 10),
          _ActivityOption('Art Session', 'art', 15),
          _ActivityOption('Hobby Time', 'hobby', 12),
          _ActivityOption('Music Practice', 'music', 13),
          _ActivityOption('Journaling', 'journal', 8),
        ];
    }
  }
}

/// Internal widget for the injection panel content
class _InjectionPanelContent extends StatelessWidget {
  const _InjectionPanelContent({
    required this.habitType,
    required this.attributeColor,
    required this.activities,
  });

  final HabitType habitType;
  final Color attributeColor;
  final List<_ActivityOption> activities;

  void _selectActivity(BuildContext context, _ActivityOption activity) {
    HapticFeedback.mediumImpact(); // Required haptic feedback

    // Return selected activity data
    Navigator.of(context).pop({
      'activity': activity.activityKey,
      'xpEarned': activity.xpValue,
      'displayName': activity.displayName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassOverlay,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          border: Border(
            top: BorderSide(
              color: attributeColor,
              width: 2,
            ),
            left: BorderSide(
              color: attributeColor.withOpacity(0.5),
              width: 1,
            ),
            right: BorderSide(
              color: attributeColor.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: attributeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SELECT ${habitType.name.toUpperCase()} ACTIVITY',
                      style: AppTextStyles.headerMedium.copyWith(
                        color: attributeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Activity list
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _ActivityTile(
                      activity: activity,
                      attributeColor: attributeColor,
                      onTap: () => _selectActivity(context, activity),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Cancel button
                Center(
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'CANCEL',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Activity selection tile
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.attributeColor,
    required this.onTap,
  });

  final _ActivityOption activity;
  final Color attributeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        splashColor: attributeColor.withOpacity(0.2),
        highlightColor: attributeColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Activity name
              Expanded(
                child: Text(
                  activity.displayName,
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              // XP value
              Text(
                '+${activity.xpValue} XP',
                style: AppTextStyles.dataSmall.copyWith(
                  color: attributeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity option data class
class _ActivityOption {
  const _ActivityOption(
    this.displayName,
    this.activityKey,
    this.xpValue,
  );

  final String displayName; // e.g., "Squats (10 reps)"
  final String activityKey; // e.g., "squats"
  final int xpValue; // Base XP value

  @override
  String toString() => displayName;
}
