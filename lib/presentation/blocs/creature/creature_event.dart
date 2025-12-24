import 'package:equatable/equatable.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Events that can be dispatched to [CreatureBloc]
///
/// These events trigger state changes and business logic for creature evolution.
sealed class CreatureEvent extends Equatable {
  const CreatureEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current creature state from storage
///
/// Dispatched when the app starts or when the creature screen is opened.
/// Emits [CreatureLoaded] with the current creature data.
class LoadCreature extends CreatureEvent {
  const LoadCreature();
}

/// Add XP to a specific attribute
///
/// This is the core event for creature progression.
/// Automatically recalculates tiers and emits [CreatureEvolved] if a tier-up occurs.
///
/// Parameters:
/// - [habitType]: Which attribute to boost (vitality/mind/soul)
/// - [xpAmount]: How much XP to add (after multipliers)
class AddXP extends CreatureEvent {
  const AddXP({
    required this.habitType,
    required this.xpAmount,
  });

  final HabitType habitType;
  final int xpAmount;

  @override
  List<Object?> get props => [habitType, xpAmount];
}

/// Reset the creature to initial state
///
/// Clears all XP and resets all tiers to 0.
/// Used for testing or when user wants to start over.
class ResetCreature extends CreatureEvent {
  const ResetCreature();
}

/// Manually update the creature's name
///
/// Allows user to customize their creature's name.
class UpdateCreatureName extends CreatureEvent {
  const UpdateCreatureName(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}
