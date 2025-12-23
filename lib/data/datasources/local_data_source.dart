import 'package:hive/hive.dart';
import 'package:client_app/data/models/creature_state.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Local data source that manages Hive boxes for offline-first data persistence.
///
/// This class provides direct access to Hive storage for creature state and habit logs.
/// All operations are synchronous and fast (local storage).
class LocalDataSource {
  // Box names (constants)
  static const String creatureBoxName = 'creature_state';
  static const String habitLogsBoxName = 'habit_logs';
  static const String settingsBoxName = 'app_settings';

  // Box references (lazy-loaded)
  Box<CreatureState>? _creatureBox;
  Box<HabitEntry>? _habitLogsBox;
  Box? _settingsBox;

  /// Initialize all Hive boxes
  ///
  /// Should be called once during app startup (in main.dart)
  /// after Hive.initFlutter() and adapter registration.
  Future<void> init() async {
    _creatureBox = await Hive.openBox<CreatureState>(creatureBoxName);
    _habitLogsBox = await Hive.openBox<HabitEntry>(habitLogsBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
  }

  /// Close all boxes (optional cleanup)
  Future<void> close() async {
    await _creatureBox?.close();
    await _habitLogsBox?.close();
    await _settingsBox?.close();
  }

  // ========== CREATURE STATE OPERATIONS ==========

  /// Get the creature state (single object, stored at index 0)
  ///
  /// If no creature exists, creates and returns a fresh one.
  Future<CreatureState> getCreatureState() async {
    final box = _creatureBox!;

    if (box.isEmpty) {
      // Create initial creature
      final initial = CreatureState.initial();
      await box.add(initial);
      return initial;
    }

    return box.getAt(0)!;
  }

  /// Save/update the creature state
  ///
  /// Always saves to index 0 (single creature per user)
  Future<void> saveCreatureState(CreatureState state) async {
    final box = _creatureBox!;

    if (box.isEmpty) {
      await box.add(state);
    } else {
      await box.putAt(0, state);
    }
  }

  /// Reset creature to initial state (for testing or user reset)
  Future<void> resetCreature() async {
    final box = _creatureBox!;
    await box.clear();

    final initial = CreatureState.initial();
    await box.add(initial);
  }

  /// Check if creature exists (for first-time user detection)
  bool hasCreature() {
    return _creatureBox?.isNotEmpty ?? false;
  }

  // ========== HABIT LOGS OPERATIONS ==========

  /// Add a new habit entry to the log
  Future<void> addHabitEntry(HabitEntry entry) async {
    await _habitLogsBox!.add(entry);
  }

  /// Get all habit entries (sorted newest first)
  List<HabitEntry> getAllHabitEntries() {
    final entries = _habitLogsBox!.values.toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get habit history with pagination
  ///
  /// Returns the most recent [limit] entries, skipping [offset] entries.
  List<HabitEntry> getHabitHistory({int limit = 50, int offset = 0}) {
    final allEntries = getAllHabitEntries();
    final endIndex = (offset + limit).clamp(0, allEntries.length);

    if (offset >= allEntries.length) return [];

    return allEntries.sublist(offset, endIndex);
  }

  /// Get habit entries filtered by type
  List<HabitEntry> getHabitEntriesByType(HabitType type) {
    final entries = _habitLogsBox!.values
        .where((entry) => entry.habitType == type)
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get habit entries within a date range
  List<HabitEntry> getHabitEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final entries = _habitLogsBox!.values
        .where(
          (entry) =>
              entry.timestamp.isAfter(startDate) &&
              entry.timestamp.isBefore(endDate),
        )
        .toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get today's habit entries
  List<HabitEntry> getTodayEntries() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getHabitEntriesByDateRange(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get total XP earned today (for daily summary)
  int getTodayTotalXP() {
    final todayEntries = getTodayEntries();
    return todayEntries.fold<int>(0, (sum, entry) => sum + entry.xpEarned);
  }

  /// Get habit entry by ID
  HabitEntry? getHabitEntryById(String id) {
    return _habitLogsBox!.values.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw Exception('Habit entry not found: $id'),
    );
  }

  /// Delete a habit entry by ID
  Future<void> deleteHabitEntry(String id) async {
    final box = _habitLogsBox!;
    final key = box.keys.firstWhere(
      (k) => box.get(k)?.id == id,
      orElse: () => throw Exception('Habit entry not found: $id'),
    );
    await box.delete(key);
  }

  /// Clear all habit logs (for testing or user reset)
  Future<void> clearHabitLogs() async {
    await _habitLogsBox!.clear();
  }

  /// Get total number of habit entries
  int getHabitLogsCount() {
    return _habitLogsBox?.length ?? 0;
  }

  // ========== APP SETTINGS OPERATIONS ==========

  /// Get a setting value by key
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Save a setting value
  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox?.put(key, value);
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  /// Check if a setting exists
  bool hasSetting(String key) {
    return _settingsBox?.containsKey(key) ?? false;
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _settingsBox?.clear();
  }

  // ========== STATISTICS & ANALYTICS ==========

  /// Get total XP earned across all time
  int getTotalLifetimeXP() {
    return _habitLogsBox!.values.fold<int>(
      0,
      (sum, entry) => sum + entry.xpEarned,
    );
  }

  /// Get streak count (consecutive days with at least one habit log)
  ///
  /// Returns 0 if no habits logged today.
  int getCurrentStreak() {
    final entries = getAllHabitEntries();
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if there's an entry today
    final hasToday = entries.any((entry) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return entryDate.isAtSameMomentAs(today);
    });

    if (!hasToday) return 0;

    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final hasEntryOnDate = entries.any((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        return entryDate.isAtSameMomentAs(checkDate);
      });

      if (!hasEntryOnDate) break;

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get statistics for a specific habit type
  Map<String, dynamic> getHabitTypeStats(HabitType type) {
    final entries = getHabitEntriesByType(type);
    final totalXP = entries.fold<int>(0, (sum, entry) => sum + entry.xpEarned);
    final avgXP = entries.isEmpty ? 0 : totalXP ~/ entries.length;

    return {
      'count': entries.length,
      'totalXP': totalXP,
      'averageXP': avgXP,
      'lastLoggedDate': entries.isNotEmpty ? entries.first.timestamp : null,
    };
  }
}
