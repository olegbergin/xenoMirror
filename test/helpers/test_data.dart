import 'package:client_app/data/models/creature_state.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Test fixture data for consistent testing.
///
/// Provides pre-configured creature states and habit entries for use in tests.
/// Use these instead of manually creating test data to ensure consistency.
class TestData {
  // Prevent instantiation
  TestData._();

  /// A creature at tier 0 with some XP
  ///
  /// XP distribution:
  /// - Vitality: 50 (50% of tier 0)
  /// - Mind: 30 (30% of tier 0)
  /// - Soul: 20 (20% of tier 0)
  static CreatureState earlyCreature() {
    return CreatureState.initial().copyWith(
      xpVitality: 50,
      xpMind: 30,
      xpSoul: 20,
      legsTier: 0,
      headTier: 0,
      armsTier: 0,
    );
  }

  /// A creature at tier 1 in all attributes
  ///
  /// XP distribution:
  /// - Vitality: 100 (start of tier 1)
  /// - Mind: 150 (mid tier 1)
  /// - Soul: 120 (early tier 1)
  static CreatureState tier1Creature() {
    return CreatureState.initial().copyWith(
      xpVitality: 100,
      xpMind: 150,
      xpSoul: 120,
      legsTier: 1,
      headTier: 1,
      armsTier: 1,
    );
  }

  /// A creature at tier 2 in all attributes
  ///
  /// XP distribution:
  /// - Vitality: 400 (start of tier 2)
  /// - Mind: 600 (mid tier 2)
  /// - Soul: 500 (early tier 2)
  static CreatureState tier2Creature() {
    return CreatureState.initial().copyWith(
      xpVitality: 400,
      xpMind: 600,
      xpSoul: 500,
      legsTier: 2,
      headTier: 2,
      armsTier: 2,
    );
  }

  /// A fully evolved creature (tier 3)
  ///
  /// XP distribution:
  /// - Vitality: 1500 (mid tier 3)
  /// - Mind: 2000 (high tier 3)
  /// - Soul: 1800 (mid-high tier 3)
  static CreatureState maxTierCreature() {
    return CreatureState.initial().copyWith(
      xpVitality: 1500,
      xpMind: 2000,
      xpSoul: 1800,
      legsTier: 3,
      headTier: 3,
      armsTier: 3,
    );
  }

  /// A creature on the threshold of evolving (tier 0 → 1)
  ///
  /// XP: 99 (one XP away from tier 1)
  static CreatureState aboutToEvolveCreature() {
    return CreatureState.initial().copyWith(
      xpVitality: 99,
      xpMind: 99,
      xpSoul: 99,
      legsTier: 0,
      headTier: 0,
      armsTier: 0,
    );
  }

  /// A creature that just evolved (tier 0 → 1)
  ///
  /// XP: 100 (exactly at tier 1 threshold)
  static CreatureState justEvolvedCreature() {
    return CreatureState.initial().copyWith(
      xpVitality: 100,
      xpMind: 100,
      xpSoul: 100,
      legsTier: 1,
      headTier: 1,
      armsTier: 1,
    );
  }

  /// Sample habit entry for testing
  ///
  /// Defaults:
  /// - Activity: squats
  /// - XP earned: 10
  /// - Habit type: vitality
  static HabitEntry sampleHabitEntry({
    String activity = 'squats',
    int xpEarned = 10,
    HabitType habitType = HabitType.vitality,
  }) {
    return HabitEntry.create(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      habitType: habitType,
      activity: activity,
      xpEarned: xpEarned,
      validationMethod: ValidationMethod.manual,
    );
  }

  /// Reading habit entry (Mind category)
  static HabitEntry readingHabitEntry({int xpEarned = 15}) {
    return HabitEntry.create(
      id: 'test-reading-${DateTime.now().millisecondsSinceEpoch}',
      habitType: HabitType.mind,
      activity: 'reading',
      xpEarned: xpEarned,
      validationMethod: ValidationMethod.manual,
    );
  }

  /// Meditation habit entry (Soul category)
  static HabitEntry meditationHabitEntry({int xpEarned = 10}) {
    return HabitEntry.create(
      id: 'test-meditation-${DateTime.now().millisecondsSinceEpoch}',
      habitType: HabitType.soul,
      activity: 'meditation',
      xpEarned: xpEarned,
      validationMethod: ValidationMethod.manual,
    );
  }

  /// Workout habit entry with camera validation
  static HabitEntry cameraValidatedWorkout() {
    return HabitEntry.create(
      id: 'test-workout-${DateTime.now().millisecondsSinceEpoch}',
      habitType: HabitType.vitality,
      activity: 'workout',
      xpEarned: 38, // 25 base * 1.5 (camera bonus)
      validationMethod: ValidationMethod.camera,
    );
  }
}
