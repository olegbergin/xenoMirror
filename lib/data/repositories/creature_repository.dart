import 'package:client_app/core/constants/xp_constants.dart';
import 'package:client_app/domain/repositories/i_creature_repository.dart';
import 'package:client_app/data/datasources/local_data_source.dart';
import 'package:client_app/data/models/creature_state.dart';

/// Concrete implementation of ICreatureRepository using local Hive storage.
///
/// Handles all creature state operations including XP updates and tier calculations.
class CreatureRepository implements ICreatureRepository {
  final LocalDataSource _localDataSource;

  CreatureRepository({required LocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<CreatureState> getCreatureState() async {
    return await _localDataSource.getCreatureState();
  }

  @override
  Future<void> updateXP({
    int? vitalityDelta,
    int? mindDelta,
    int? soulDelta,
  }) async {
    // Get current state
    final current = await getCreatureState();

    // Calculate new XP values (clamped to valid range)
    final newVitalityXP = (current.xpVitality + (vitalityDelta ?? 0))
        .clamp(0, XpConstants.maxXP);
    final newMindXP =
        (current.xpMind + (mindDelta ?? 0)).clamp(0, XpConstants.maxXP);
    final newSoulXP =
        (current.xpSoul + (soulDelta ?? 0)).clamp(0, XpConstants.maxXP);

    // Calculate new tiers based on XP
    final newLegsTier = XpConstants.getTierForXP(newVitalityXP);
    final newHeadTier = XpConstants.getTierForXP(newMindXP);
    final newArmsTier = XpConstants.getTierForXP(newSoulXP);

    // Create updated state
    final updated = current.copyWith(
      xpVitality: newVitalityXP,
      xpMind: newMindXP,
      xpSoul: newSoulXP,
      legsTier: newLegsTier,
      headTier: newHeadTier,
      armsTier: newArmsTier,
      lastUpdated: DateTime.now(),
    );

    // Save to storage
    await _localDataSource.saveCreatureState(updated);
  }

  @override
  Future<void> saveCreatureState(CreatureState state) async {
    // Ensure lastUpdated is set
    final stateToSave = state.copyWith(lastUpdated: DateTime.now());
    await _localDataSource.saveCreatureState(stateToSave);
  }

  @override
  Future<void> resetCreature() async {
    await _localDataSource.resetCreature();
  }

  @override
  Future<bool> hasCreature() async {
    return _localDataSource.hasCreature();
  }

  @override
  Future<double> getProgressForAttribute(String attribute) async {
    final creature = await getCreatureState();

    switch (attribute.toLowerCase()) {
      case 'vitality':
        return creature.vitalityProgress;
      case 'mind':
        return creature.mindProgress;
      case 'soul':
        return creature.soulProgress;
      default:
        throw ArgumentError('Invalid attribute: $attribute');
    }
  }

  // Additional helper methods

  /// Get XP and tier info for all attributes
  Future<Map<String, Map<String, dynamic>>> getAllAttributeInfo() async {
    final creature = await getCreatureState();

    return {
      'vitality': {
        'xp': creature.xpVitality,
        'tier': creature.legsTier,
        'progress': creature.vitalityProgress,
      },
      'mind': {
        'xp': creature.xpMind,
        'tier': creature.headTier,
        'progress': creature.mindProgress,
      },
      'soul': {
        'xp': creature.xpSoul,
        'tier': creature.armsTier,
        'progress': creature.soulProgress,
      },
    };
  }

  /// Check if any attribute will evolve with given XP deltas
  ///
  /// Returns map of attribute names to evolution info:
  /// { 'vitality': { 'willEvolve': true, 'newTier': 2 }, ... }
  Future<Map<String, Map<String, dynamic>>> checkEvolutionPreview({
    int? vitalityDelta,
    int? mindDelta,
    int? soulDelta,
  }) async {
    final current = await getCreatureState();

    final newVitalityXP = current.xpVitality + (vitalityDelta ?? 0);
    final newMindXP = current.xpMind + (mindDelta ?? 0);
    final newSoulXP = current.xpSoul + (soulDelta ?? 0);

    final newLegsTier = XpConstants.getTierForXP(newVitalityXP);
    final newHeadTier = XpConstants.getTierForXP(newMindXP);
    final newArmsTier = XpConstants.getTierForXP(newSoulXP);

    return {
      'vitality': {
        'willEvolve': newLegsTier > current.legsTier,
        'currentTier': current.legsTier,
        'newTier': newLegsTier,
      },
      'mind': {
        'willEvolve': newHeadTier > current.headTier,
        'currentTier': current.headTier,
        'newTier': newHeadTier,
      },
      'soul': {
        'willEvolve': newArmsTier > current.armsTier,
        'currentTier': current.armsTier,
        'newTier': newArmsTier,
      },
    };
  }

  /// Get how much XP is needed to reach next tier for an attribute
  Future<int> getXPToNextTier(String attribute) async {
    final creature = await getCreatureState();

    switch (attribute.toLowerCase()) {
      case 'vitality':
        final thresholds = XpThresholds.forTier(creature.legsTier);
        return (thresholds.nextTierXp - creature.xpVitality).clamp(0, 9999);
      case 'mind':
        final thresholds = XpThresholds.forTier(creature.headTier);
        return (thresholds.nextTierXp - creature.xpMind).clamp(0, 9999);
      case 'soul':
        final thresholds = XpThresholds.forTier(creature.armsTier);
        return (thresholds.nextTierXp - creature.xpSoul).clamp(0, 9999);
      default:
        throw ArgumentError('Invalid attribute: $attribute');
    }
  }
}
