/// XP progression constants and thresholds for creature evolution.
///
/// This file defines the core game mechanics for XP earning and tier progression.
/// Uses a polynomial curve for balanced progression (fast early wins, sustainable mid-game).
class XpConstants {
  // Prevent instantiation
  XpConstants._();

  // Tier Thresholds (Polynomial Progression)
  // Tier 0 → 1: 100 XP (quick early win)
  // Tier 1 → 2: 400 XP cumulative (300 more)
  // Tier 2 → 3: 1000 XP cumulative (600 more)
  static const int tier1Threshold = 100;
  static const int tier2Threshold = 400;
  static const int tier3Threshold = 1000;
  static const int maxXP = 9999; // Cap for overflow prevention

  // Base XP awards per activity type
  static const Map<String, int> activityXP = {
    // VITALITY → Legs & Core
    'squats': 10, // Per 10 squats
    'pushups': 12, // Per 10 pushups
    'running': 20, // Per 10 minutes
    'walking': 15, // Per 15 minutes
    'sleep': 15, // Per 8 hours quality sleep
    'workout': 25, // Per gym session
    // MIND → Head & Sensors
    'reading': 15, // Per 15 minutes
    'study': 12, // Per 15 minutes
    'planning': 10, // Per planning session
    'learning': 18, // Per course/tutorial session
    'writing': 14, // Per 15 minutes
    // SOUL → Arms & Aura
    'meditation': 10, // Per 10 minutes
    'art': 15, // Per art session
    'hobby': 12, // Per hobby session
    'music': 13, // Per practice session
    'journal': 8, // Per journal entry
  };

  // Bonus multipliers
  static const double cameraValidationBonus = 1.5; // +50% XP if validated by AI
  static const double streakBonus = 1.2; // Future: +20% for 3-day streak
  static const double perfectDayBonus =
      2.0; // Future: +100% for all 3 habit types in one day

  /// Get the tier level for a given XP amount
  static int getTierForXP(int xp) {
    if (xp >= tier3Threshold) return 3;
    if (xp >= tier2Threshold) return 2;
    if (xp >= tier1Threshold) return 1;
    return 0;
  }

  /// Calculate XP progress percentage within current tier (0.0 - 1.0)
  static double calculateProgress(int currentXP, int currentTier) {
    final thresholds = XpThresholds.forTier(currentTier);
    if (currentXP >= thresholds.nextTierXp) return 1.0;

    final tierRange = thresholds.nextTierXp - thresholds.currentTierXp;
    final currentProgress = currentXP - thresholds.currentTierXp;

    return (currentProgress / tierRange).clamp(0.0, 1.0);
  }

  /// Get base XP for an activity (returns default if activity not found)
  static int getActivityXP(String activity, {int defaultXP = 10}) {
    return activityXP[activity.toLowerCase()] ?? defaultXP;
  }

  /// Calculate final XP with multipliers applied
  static int calculateFinalXP(
    int baseXP, {
    bool cameraValidated = false,
    bool hasStreak = false,
  }) {
    double finalXP = baseXP.toDouble();

    if (cameraValidated) {
      finalXP *= cameraValidationBonus;
    }

    if (hasStreak) {
      finalXP *= streakBonus;
    }

    return finalXP.round();
  }
}

/// Represents the XP thresholds for a specific tier.
///
/// Used to calculate progress bars and determine when to trigger evolution.
class XpThresholds {
  /// XP value at the start of this tier
  final int currentTierXp;

  /// XP value needed to reach the next tier
  final int nextTierXp;

  /// Current tier level (0-3)
  final int tier;

  const XpThresholds({
    required this.currentTierXp,
    required this.nextTierXp,
    required this.tier,
  });

  /// Factory constructor to get thresholds for a given tier
  factory XpThresholds.forTier(int tier) {
    switch (tier) {
      case 0:
        return const XpThresholds(
          currentTierXp: 0,
          nextTierXp: XpConstants.tier1Threshold,
          tier: 0,
        );
      case 1:
        return const XpThresholds(
          currentTierXp: XpConstants.tier1Threshold,
          nextTierXp: XpConstants.tier2Threshold,
          tier: 1,
        );
      case 2:
        return const XpThresholds(
          currentTierXp: XpConstants.tier2Threshold,
          nextTierXp: XpConstants.tier3Threshold,
          tier: 2,
        );
      case 3:
        return const XpThresholds(
          currentTierXp: XpConstants.tier3Threshold,
          nextTierXp: XpConstants.maxXP,
          tier: 3,
        );
      default:
        return const XpThresholds(
          currentTierXp: 0,
          nextTierXp: XpConstants.tier1Threshold,
          tier: 0,
        );
    }
  }

  /// XP range for this tier
  int get tierRange => nextTierXp - currentTierXp;

  /// Check if this is the max tier
  bool get isMaxTier => tier >= 3;

  @override
  String toString() {
    return 'XpThresholds(tier: $tier, range: $currentTierXp-$nextTierXp)';
  }
}
