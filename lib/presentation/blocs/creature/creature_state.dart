import 'package:equatable/equatable.dart';
import 'package:client_app/data/models/creature_state.dart';

/// States emitted by [CreatureBloc]
///
/// Note: This is different from the data model [CreatureState].
/// These are UI states that represent the current status of creature operations.
sealed class CreatureBlocState extends Equatable {
  const CreatureBlocState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any creature data is loaded
class CreatureInitial extends CreatureBlocState {
  const CreatureInitial();
}

/// Loading creature data from storage
class CreatureLoading extends CreatureBlocState {
  const CreatureLoading();
}

/// Creature data successfully loaded
///
/// This is the normal state during app usage.
/// Contains the current creature with all XP and tier data.
class CreatureLoaded extends CreatureBlocState {
  const CreatureLoaded(this.creature);

  final CreatureState creature;

  @override
  List<Object?> get props => [creature];
}

/// Creature just evolved (tier increased)
///
/// This is a transient state emitted when XP crosses a tier threshold.
/// Used to trigger animations and Unity messages.
///
/// After emitting this state, the bloc will emit [CreatureLoaded] with the updated creature.
class CreatureEvolved extends CreatureBlocState {
  const CreatureEvolved({
    required this.creature,
    required this.evolvedBodyPart,
    required this.oldTier,
    required this.newTier,
  });

  final CreatureState creature;
  final String evolvedBodyPart; // 'legs', 'head', or 'arms'
  final int oldTier; // Previous tier (0-2)
  final int newTier; // New tier (1-3)

  @override
  List<Object?> get props => [creature, evolvedBodyPart, oldTier, newTier];

  /// Get user-friendly message for the evolution
  String get evolutionMessage {
    final bodyPartDisplay = evolvedBodyPart.toUpperCase();
    return 'EVOLUTION DETECTED: $bodyPartDisplay → TIER $newTier';
  }
}

/// Error occurred during creature operations
class CreatureError extends CreatureBlocState {
  const CreatureError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
