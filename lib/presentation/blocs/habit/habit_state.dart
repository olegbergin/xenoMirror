import 'package:equatable/equatable.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// States emitted by [HabitBloc]
///
/// Represents the current status of habit logging and history operations.
sealed class HabitBlocState extends Equatable {
  const HabitBlocState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any habit data is loaded
class HabitInitial extends HabitBlocState {
  const HabitInitial();
}

/// Loading habit data from storage
class HabitLoading extends HabitBlocState {
  const HabitLoading();
}

/// Today's habit data successfully loaded
///
/// This is the normal state on the home screen.
/// Contains today's entries, total XP, and current streak.
class HabitLoaded extends HabitBlocState {
  const HabitLoaded({
    required this.todayEntries,
    required this.todayTotalXP,
    required this.currentStreak,
  });

  final List<HabitEntry> todayEntries;
  final int todayTotalXP;
  final int currentStreak;

  @override
  List<Object?> get props => [todayEntries, todayTotalXP, currentStreak];

  /// Get count of today's entries by type
  int getCountByType(HabitType type) {
    return todayEntries.where((e) => e.habitType == type).length;
  }

  /// Get total XP earned today by type
  int getXPByType(HabitType type) {
    return todayEntries
        .where((e) => e.habitType == type)
        .fold(0, (sum, e) => sum + e.xpEarned);
  }

  /// Check if any habits logged today
  bool get hasLogsToday => todayEntries.isNotEmpty;
}

/// Habit just logged successfully
///
/// This is a transient state emitted after [LogHabit] event succeeds.
/// Used to show success feedback (toast, animation).
///
/// After emitting this state, the bloc will reload today's data
/// and emit [HabitLoaded] with updated totals.
class HabitLogged extends HabitBlocState {
  const HabitLogged({
    required this.entry,
    required this.isFirstOfType,
  });

  final HabitEntry entry;
  final bool isFirstOfType; // True if this is the first habit of this type today

  @override
  List<Object?> get props => [entry, isFirstOfType];

  /// Get success message for the logged habit
  String get successMessage {
    final typeLabel = entry.habitType.name.toUpperCase();
    return '+${entry.xpEarned} XP ($typeLabel)';
  }
}

/// Complete habit history loaded
///
/// Used for history/stats screens.
/// Contains paginated list of all habit entries.
class HabitHistoryLoaded extends HabitBlocState {
  const HabitHistoryLoaded({
    required this.entries,
    required this.totalCount,
    required this.hasMore,
  });

  final List<HabitEntry> entries;
  final int totalCount;
  final bool hasMore; // True if more entries available beyond current page

  @override
  List<Object?> get props => [entries, totalCount, hasMore];
}

/// Statistics for a specific habit type loaded
///
/// Contains aggregated stats for Vitality/Mind/Soul.
class HabitStatsLoaded extends HabitBlocState {
  const HabitStatsLoaded({
    required this.habitType,
    required this.count,
    required this.totalXP,
    required this.averageXP,
    this.lastLoggedDate,
  });

  final HabitType habitType;
  final int count;
  final int totalXP;
  final double averageXP;
  final DateTime? lastLoggedDate;

  @override
  List<Object?> get props => [
        habitType,
        count,
        totalXP,
        averageXP,
        lastLoggedDate,
      ];
}

/// Habit entry deleted successfully
class HabitDeleted extends HabitBlocState {
  const HabitDeleted(this.entryId);

  final String entryId;

  @override
  List<Object?> get props => [entryId];
}

/// All habit logs cleared
class HabitCleared extends HabitBlocState {
  const HabitCleared();
}

/// Error occurred during habit operations
class HabitError extends HabitBlocState {
  const HabitError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
