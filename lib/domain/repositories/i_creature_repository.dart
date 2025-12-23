import 'package:client_app/data/models/creature_state.dart';

/// Repository interface for creature state management.
///
/// Defines the contract for accessing and manipulating creature data.
/// Implementations can use different data sources (Hive, Supabase, etc.)
/// without changing business logic.
abstract class ICreatureRepository {
  /// Get the current creature state
  ///
  /// Returns the user's creature. If no creature exists, creates a fresh one.
  Future<CreatureState> getCreatureState();

  /// Update XP for one or more attributes
  ///
  /// Pass delta values (can be positive or negative).
  /// Automatically recalculates tiers based on new XP values.
  ///
  /// Example:
  /// ```dart
  /// await repository.updateXP(vitalityDelta: 10); // Add 10 XP to Vitality
  /// ```
  Future<void> updateXP({int? vitalityDelta, int? mindDelta, int? soulDelta});

  /// Save/update the complete creature state
  ///
  /// Use this for bulk updates or when you have a modified CreatureState object.
  Future<void> saveCreatureState(CreatureState state);

  /// Reset creature to initial state
  ///
  /// Useful for testing or when user wants to start over.
  Future<void> resetCreature();

  /// Check if creature exists
  ///
  /// Returns false on first app launch (no creature created yet).
  Future<bool> hasCreature();

  /// Get XP progress percentage for a specific attribute (0.0 - 1.0)
  ///
  /// Used for UI progress bars and Unity shader glow intensity.
  Future<double> getProgressForAttribute(String attribute);
}
