import 'package:equatable/equatable.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Events that can be dispatched to [HabitBloc]
///
/// These events trigger habit logging operations and statistics queries.
sealed class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's habit entries
///
/// Fetches all habits logged today plus today's total XP and current streak.
/// Dispatched when the home screen opens.
class LoadTodayHabits extends HabitEvent {
  const LoadTodayHabits();
}

/// Log a new habit activity
///
/// Core event for habit tracking.
/// Creates a new habit entry and saves it to storage.
///
/// Parameters:
/// - [habitType]: Vitality, Mind, or Soul
/// - [activity]: Activity name (e.g., 'squats', 'reading')
/// - [xpEarned]: XP amount after multipliers
/// - [validationMethod]: Manual or Camera
/// - [metadata]: Optional additional context (reps, duration, etc.)
class LogHabit extends HabitEvent {
  const LogHabit({
    required this.habitType,
    required this.activity,
    required this.xpEarned,
    required this.validationMethod,
    this.metadata,
  });

  final HabitType habitType;
  final String activity;
  final int xpEarned;
  final ValidationMethod validationMethod;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        habitType,
        activity,
        xpEarned,
        validationMethod,
        metadata,
      ];
}

/// Load complete habit history
///
/// Fetches all habit entries (paginated if needed).
/// Used for history/stats screens.
class LoadHabitHistory extends HabitEvent {
  const LoadHabitHistory({
    this.limit = 50,
    this.offset = 0,
  });

  final int limit;
  final int offset;

  @override
  List<Object?> get props => [limit, offset];
}

/// Load statistics for a specific habit type
///
/// Fetches count, totalXP, averageXP for Vitality/Mind/Soul.
class LoadHabitTypeStats extends HabitEvent {
  const LoadHabitTypeStats(this.habitType);

  final HabitType habitType;

  @override
  List<Object?> get props => [habitType];
}

/// Delete a specific habit entry
///
/// Removes entry from storage.
/// Used if user wants to correct a logging mistake.
class DeleteHabit extends HabitEvent {
  const DeleteHabit(this.entryId);

  final String entryId;

  @override
  List<Object?> get props => [entryId];
}

/// Clear all habit logs
///
/// Removes all entries (for testing or user reset).
class ClearAllHabits extends HabitEvent {
  const ClearAllHabits();
}
