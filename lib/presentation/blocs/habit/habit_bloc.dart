import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:client_app/domain/repositories/i_habit_repository.dart';
import 'package:client_app/data/models/habit_entry.dart';
import 'package:client_app/presentation/blocs/habit/habit_event.dart';
import 'package:client_app/presentation/blocs/habit/habit_state.dart';

/// Business logic for habit logging and history
///
/// This BLoC handles all habit-related operations:
/// - Loading today's habits and stats
/// - Logging new habit activities
/// - Loading habit history
/// - Deleting habit entries
/// - Calculating statistics
///
/// Emits UI states ([HabitBlocState]) based on data changes.
class HabitBloc extends Bloc<HabitEvent, HabitBlocState> {
  HabitBloc({
    required IHabitRepository habitRepository,
  })  : _habitRepository = habitRepository,
        _uuid = const Uuid(),
        super(const HabitInitial()) {
    // Register event handlers
    on<LoadTodayHabits>(_onLoadTodayHabits);
    on<LogHabit>(_onLogHabit);
    on<LoadHabitHistory>(_onLoadHabitHistory);
    on<LoadHabitTypeStats>(_onLoadHabitTypeStats);
    on<DeleteHabit>(_onDeleteHabit);
    on<ClearAllHabits>(_onClearAllHabits);
  }

  final IHabitRepository _habitRepository;
  final Uuid _uuid;

  /// Handle [LoadTodayHabits] event
  ///
  /// Fetches today's entries, total XP, and current streak.
  Future<void> _onLoadTodayHabits(
    LoadTodayHabits event,
    Emitter<HabitBlocState> emit,
  ) async {
    emit(const HabitLoading());

    try {
      final todayEntries = await _habitRepository.getTodayEntries();
      final todayTotalXP = await _habitRepository.getTodayTotalXP();
      final currentStreak = await _habitRepository.getCurrentStreak();

      emit(HabitLoaded(
        todayEntries: todayEntries,
        todayTotalXP: todayTotalXP,
        currentStreak: currentStreak,
      ));
    } catch (e) {
      emit(HabitError('Failed to load today\'s habits: $e'));
    }
  }

  /// Handle [LogHabit] event
  ///
  /// Core habit logging logic:
  /// 1. Create new HabitEntry with unique ID
  /// 2. Save to repository
  /// 3. Check if this is first of this type today (for UI feedback)
  /// 4. Emit HabitLogged state (transient success state)
  /// 5. Reload today's data and emit HabitLoaded
  Future<void> _onLogHabit(
    LogHabit event,
    Emitter<HabitBlocState> emit,
  ) async {
    try {
      // Get current today's entries to check if this is first of type
      final currentEntries = await _habitRepository.getTodayEntries();
      final isFirstOfType = !currentEntries.any(
        (e) => e.habitType == event.habitType,
      );

      // Create new habit entry
      final entry = HabitEntry.create(
        id: _uuid.v4(),
        habitType: event.habitType,
        activity: event.activity,
        xpEarned: event.xpEarned,
        validationMethod: event.validationMethod,
        metadata: event.metadata,
      );

      // Save to repository
      await _habitRepository.addEntry(entry);

      // Emit success state (transient)
      emit(HabitLogged(
        entry: entry,
        isFirstOfType: isFirstOfType,
      ));

      // Reload today's data for updated UI
      final todayEntries = await _habitRepository.getTodayEntries();
      final todayTotalXP = await _habitRepository.getTodayTotalXP();
      final currentStreak = await _habitRepository.getCurrentStreak();

      emit(HabitLoaded(
        todayEntries: todayEntries,
        todayTotalXP: todayTotalXP,
        currentStreak: currentStreak,
      ));
    } catch (e) {
      emit(HabitError('Failed to log habit: $e'));
    }
  }

  /// Handle [LoadHabitHistory] event
  ///
  /// Fetches paginated habit history for history/stats screens.
  Future<void> _onLoadHabitHistory(
    LoadHabitHistory event,
    Emitter<HabitBlocState> emit,
  ) async {
    emit(const HabitLoading());

    try {
      final entries = await _habitRepository.getHistory(
        limit: event.limit,
        offset: event.offset,
      );
      final totalCount = await _habitRepository.getEntryCount();
      final hasMore = (event.offset + entries.length) < totalCount;

      emit(HabitHistoryLoaded(
        entries: entries,
        totalCount: totalCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(HabitError('Failed to load habit history: $e'));
    }
  }

  /// Handle [LoadHabitTypeStats] event
  ///
  /// Fetches aggregated statistics for a specific habit type.
  Future<void> _onLoadHabitTypeStats(
    LoadHabitTypeStats event,
    Emitter<HabitBlocState> emit,
  ) async {
    emit(const HabitLoading());

    try {
      final stats = await _habitRepository.getHabitTypeStats(event.habitType);

      emit(HabitStatsLoaded(
        habitType: event.habitType,
        count: stats['count'] as int,
        totalXP: stats['totalXP'] as int,
        averageXP: stats['averageXP'] as double,
        lastLoggedDate: stats['lastLoggedDate'] as DateTime?,
      ));
    } catch (e) {
      emit(HabitError('Failed to load habit stats: $e'));
    }
  }

  /// Handle [DeleteHabit] event
  ///
  /// Removes a habit entry from storage.
  Future<void> _onDeleteHabit(
    DeleteHabit event,
    Emitter<HabitBlocState> emit,
  ) async {
    try {
      await _habitRepository.deleteEntry(event.entryId);
      emit(HabitDeleted(event.entryId));

      // Reload today's data after deletion
      final todayEntries = await _habitRepository.getTodayEntries();
      final todayTotalXP = await _habitRepository.getTodayTotalXP();
      final currentStreak = await _habitRepository.getCurrentStreak();

      emit(HabitLoaded(
        todayEntries: todayEntries,
        todayTotalXP: todayTotalXP,
        currentStreak: currentStreak,
      ));
    } catch (e) {
      emit(HabitError('Failed to delete habit: $e'));
    }
  }

  /// Handle [ClearAllHabits] event
  ///
  /// Removes all habit entries (for testing or user reset).
  Future<void> _onClearAllHabits(
    ClearAllHabits event,
    Emitter<HabitBlocState> emit,
  ) async {
    emit(const HabitLoading());

    try {
      await _habitRepository.clearAll();
      emit(const HabitCleared());

      // Reload empty state
      emit(const HabitLoaded(
        todayEntries: [],
        todayTotalXP: 0,
        currentStreak: 0,
      ));
    } catch (e) {
      emit(HabitError('Failed to clear habits: $e'));
    }
  }
}
