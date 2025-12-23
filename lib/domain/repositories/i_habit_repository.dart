import 'package:client_app/data/models/habit_entry.dart';

/// Repository interface for habit logging and history.
///
/// Defines the contract for accessing habit log data.
/// Implementations can use different data sources without changing business logic.
abstract class IHabitRepository {
  /// Add a new habit entry
  ///
  /// Logs a completed activity with XP earned and validation method.
  Future<void> addEntry(HabitEntry entry);

  /// Get all habit entries (newest first)
  ///
  /// Returns complete habit history sorted by timestamp descending.
  Future<List<HabitEntry>> getAllEntries();

  /// Get paginated habit history
  ///
  /// Returns [limit] most recent entries, skipping [offset] entries.
  /// Useful for infinite scrolling or "load more" functionality.
  Future<List<HabitEntry>> getHistory({int limit = 50, int offset = 0});

  /// Get entries filtered by habit type
  ///
  /// Returns all entries for a specific type (Vitality, Mind, or Soul).
  Future<List<HabitEntry>> getEntriesByType(HabitType type);

  /// Get entries within a date range
  ///
  /// Useful for weekly/monthly statistics views.
  Future<List<HabitEntry>> getEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get today's habit entries
  ///
  /// Returns all habits logged today (useful for daily summary).
  Future<List<HabitEntry>> getTodayEntries();

  /// Get total XP earned today
  ///
  /// Sum of all XP from today's habit entries.
  Future<int> getTodayTotalXP();

  /// Get a specific habit entry by ID
  ///
  /// Throws exception if not found.
  Future<HabitEntry> getEntryById(String id);

  /// Delete a habit entry
  ///
  /// Removes entry from storage (cannot be undone).
  Future<void> deleteEntry(String id);

  /// Clear all habit logs
  ///
  /// Removes all entries (for testing or user reset).
  Future<void> clearAll();

  /// Get total number of logged habits
  Future<int> getEntryCount();

  /// Get total lifetime XP earned
  ///
  /// Sum of all XP across all habit entries ever logged.
  Future<int> getTotalLifetimeXP();

  /// Get current streak (consecutive days with habits)
  ///
  /// Returns 0 if no habits logged today.
  Future<int> getCurrentStreak();

  /// Get statistics for a specific habit type
  ///
  /// Returns map with: count, totalXP, averageXP, lastLoggedDate
  Future<Map<String, dynamic>> getHabitTypeStats(HabitType type);
}
