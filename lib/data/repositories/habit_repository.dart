import '../../domain/repositories/i_habit_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/habit_entry.dart';

/// Concrete implementation of IHabitRepository using local Hive storage.
///
/// Handles all habit logging operations and history queries.
class HabitRepository implements IHabitRepository {
  final LocalDataSource _localDataSource;

  HabitRepository({required LocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<void> addEntry(HabitEntry entry) async {
    await _localDataSource.addHabitEntry(entry);
  }

  @override
  Future<List<HabitEntry>> getAllEntries() async {
    return _localDataSource.getAllHabitEntries();
  }

  @override
  Future<List<HabitEntry>> getHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return _localDataSource.getHabitHistory(
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<HabitEntry>> getEntriesByType(HabitType type) async {
    return _localDataSource.getHabitEntriesByType(type);
  }

  @override
  Future<List<HabitEntry>> getEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _localDataSource.getHabitEntriesByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<HabitEntry>> getTodayEntries() async {
    return _localDataSource.getTodayEntries();
  }

  @override
  Future<int> getTodayTotalXP() async {
    return _localDataSource.getTodayTotalXP();
  }

  @override
  Future<HabitEntry> getEntryById(String id) async {
    final entry = _localDataSource.getHabitEntryById(id);
    if (entry == null) {
      throw Exception('Habit entry not found: $id');
    }
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _localDataSource.deleteHabitEntry(id);
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearHabitLogs();
  }

  @override
  Future<int> getEntryCount() async {
    return _localDataSource.getHabitLogsCount();
  }

  @override
  Future<int> getTotalLifetimeXP() async {
    return _localDataSource.getTotalLifetimeXP();
  }

  @override
  Future<int> getCurrentStreak() async {
    return _localDataSource.getCurrentStreak();
  }

  @override
  Future<Map<String, dynamic>> getHabitTypeStats(HabitType type) async {
    return _localDataSource.getHabitTypeStats(type);
  }

  // Additional helper methods

  /// Get weekly summary (last 7 days)
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final entries = await getEntriesByDateRange(
      startDate: weekAgo,
      endDate: now,
    );

    final totalXP = entries.fold<int>(0, (sum, e) => sum + e.xpEarned);
    final avgXPPerDay = entries.isEmpty ? 0 : totalXP ~/ 7;

    // Count by habit type
    final vitalityCount = entries.where((e) => e.habitType == HabitType.vitality).length;
    final mindCount = entries.where((e) => e.habitType == HabitType.mind).length;
    final soulCount = entries.where((e) => e.habitType == HabitType.soul).length;

    return {
      'totalEntries': entries.length,
      'totalXP': totalXP,
      'averageXPPerDay': avgXPPerDay,
      'vitalityCount': vitalityCount,
      'mindCount': mindCount,
      'soulCount': soulCount,
      'mostActiveType': _getMostActiveType(vitalityCount, mindCount, soulCount),
    };
  }

  /// Get monthly summary (last 30 days)
  Future<Map<String, dynamic>> getMonthlySummary() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final entries = await getEntriesByDateRange(
      startDate: monthAgo,
      endDate: now,
    );

    final totalXP = entries.fold<int>(0, (sum, e) => sum + e.xpEarned);
    final avgXPPerDay = entries.isEmpty ? 0 : totalXP ~/ 30;

    return {
      'totalEntries': entries.length,
      'totalXP': totalXP,
      'averageXPPerDay': avgXPPerDay,
    };
  }

  /// Check if user has logged all three habit types today (for perfect day bonus)
  Future<bool> hasLoggedAllTypesToday() async {
    final todayEntries = await getTodayEntries();

    final hasVitality = todayEntries.any((e) => e.habitType == HabitType.vitality);
    final hasMind = todayEntries.any((e) => e.habitType == HabitType.mind);
    final hasSoul = todayEntries.any((e) => e.habitType == HabitType.soul);

    return hasVitality && hasMind && hasSoul;
  }

  /// Get the most frequently logged activity name
  Future<String?> getMostFrequentActivity() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return null;

    final activityCounts = <String, int>{};
    for (final entry in entries) {
      activityCounts[entry.activity] = (activityCounts[entry.activity] ?? 0) + 1;
    }

    final sorted = activityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  String _getMostActiveType(int vitalityCount, int mindCount, int soulCount) {
    if (vitalityCount >= mindCount && vitalityCount >= soulCount) {
      return 'vitality';
    } else if (mindCount >= soulCount) {
      return 'mind';
    } else {
      return 'soul';
    }
  }
}
