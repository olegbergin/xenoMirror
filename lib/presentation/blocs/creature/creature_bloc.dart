import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_app/domain/repositories/i_creature_repository.dart';
import 'package:client_app/data/models/habit_entry.dart';
import 'package:client_app/presentation/blocs/creature/creature_event.dart';
import 'package:client_app/presentation/blocs/creature/creature_state.dart';

/// Business logic for creature evolution and XP management
///
/// This BLoC handles all creature-related operations:
/// - Loading creature state from storage
/// - Adding XP and detecting tier-ups
/// - Resetting creature
/// - Updating creature name
///
/// Emits UI states ([CreatureBlocState]) based on data changes.
class CreatureBloc extends Bloc<CreatureEvent, CreatureBlocState> {
  CreatureBloc({
    required ICreatureRepository creatureRepository,
  })  : _creatureRepository = creatureRepository,
        super(const CreatureInitial()) {
    // Register event handlers
    on<LoadCreature>(_onLoadCreature);
    on<AddXP>(_onAddXP);
    on<ResetCreature>(_onResetCreature);
    on<UpdateCreatureName>(_onUpdateCreatureName);
  }

  final ICreatureRepository _creatureRepository;

  /// Handle [LoadCreature] event
  ///
  /// Fetches current creature state from repository.
  /// Creates a new creature if none exists (first app launch).
  Future<void> _onLoadCreature(
    LoadCreature event,
    Emitter<CreatureBlocState> emit,
  ) async {
    emit(const CreatureLoading());

    try {
      final creature = await _creatureRepository.getCreatureState();
      emit(CreatureLoaded(creature));
    } catch (e) {
      emit(CreatureError('Failed to load creature: $e'));
    }
  }

  /// Handle [AddXP] event
  ///
  /// Core logic for creature progression:
  /// 1. Get current creature state
  /// 2. Store old tier values
  /// 3. Add XP via repository (triggers tier recalculation)
  /// 4. Get updated creature state
  /// 5. Compare tiers to detect evolution
  /// 6. Emit appropriate state (CreatureEvolved or CreatureLoaded)
  Future<void> _onAddXP(
    AddXP event,
    Emitter<CreatureBlocState> emit,
  ) async {
    try {
      // Get current state before update
      final oldCreature = await _creatureRepository.getCreatureState();
      final oldTiers = {
        'legs': oldCreature.legsTier,
        'head': oldCreature.headTier,
        'arms': oldCreature.armsTier,
      };

      // Update XP based on habit type
      switch (event.habitType) {
        case HabitType.vitality:
          await _creatureRepository.updateXP(vitalityDelta: event.xpAmount);
        case HabitType.mind:
          await _creatureRepository.updateXP(mindDelta: event.xpAmount);
        case HabitType.soul:
          await _creatureRepository.updateXP(soulDelta: event.xpAmount);
      }

      // Get updated state after XP addition
      final newCreature = await _creatureRepository.getCreatureState();
      final newTiers = {
        'legs': newCreature.legsTier,
        'head': newCreature.headTier,
        'arms': newCreature.armsTier,
      };

      // Check if any tier increased (evolution detected)
      String? evolvedBodyPart;
      int? oldTier;
      int? newTier;

      for (final bodyPart in ['legs', 'head', 'arms']) {
        if (newTiers[bodyPart]! > oldTiers[bodyPart]!) {
          evolvedBodyPart = bodyPart;
          oldTier = oldTiers[bodyPart];
          newTier = newTiers[bodyPart];
          break; // Only one body part evolves per XP addition
        }
      }

      // Emit appropriate state
      if (evolvedBodyPart != null && oldTier != null && newTier != null) {
        // Evolution occurred!
        emit(CreatureEvolved(
          creature: newCreature,
          evolvedBodyPart: evolvedBodyPart,
          oldTier: oldTier,
          newTier: newTier,
        ));

        // After showing evolution state, transition back to loaded state
        // This allows UI to show evolution animation then return to normal
        emit(CreatureLoaded(newCreature));
      } else {
        // No evolution, just XP increase
        emit(CreatureLoaded(newCreature));
      }
    } catch (e) {
      emit(CreatureError('Failed to add XP: $e'));
    }
  }

  /// Handle [ResetCreature] event
  ///
  /// Resets creature to initial state (all XP = 0, all tiers = 0).
  Future<void> _onResetCreature(
    ResetCreature event,
    Emitter<CreatureBlocState> emit,
  ) async {
    emit(const CreatureLoading());

    try {
      await _creatureRepository.resetCreature();
      final creature = await _creatureRepository.getCreatureState();
      emit(CreatureLoaded(creature));
    } catch (e) {
      emit(CreatureError('Failed to reset creature: $e'));
    }
  }

  /// Handle [UpdateCreatureName] event
  ///
  /// Updates the creature's display name.
  Future<void> _onUpdateCreatureName(
    UpdateCreatureName event,
    Emitter<CreatureBlocState> emit,
  ) async {
    try {
      final currentCreature = await _creatureRepository.getCreatureState();
      final updatedCreature = currentCreature.copyWith(
        creatureName: event.name,
        lastUpdated: DateTime.now(),
      );
      await _creatureRepository.saveCreatureState(updatedCreature);
      emit(CreatureLoaded(updatedCreature));
    } catch (e) {
      emit(CreatureError('Failed to update creature name: $e'));
    }
  }
}
