import 'package:hive/hive.dart';
import 'package:client_app/core/constants/xp_constants.dart';

part 'creature_state.g.dart';

/// Represents the complete state of the user's creature.
///
/// This model tracks XP for each attribute (Vitality, Mind, Soul),
/// the corresponding visual tier for each body part,
/// and provides helper methods for calculating progression.
///
/// Stored in Hive as a single object (only one creature per user).
@HiveType(typeId: 0)
class CreatureState extends HiveObject {
  /// Current XP for VITALITY attribute (affects Legs tier)
  @HiveField(0)
  int xpVitality;

  /// Current XP for MIND attribute (affects Head tier)
  @HiveField(1)
  int xpMind;

  /// Current XP for SOUL attribute (affects Arms tier)
  @HiveField(2)
  int xpSoul;

  /// Visual tier for legs (0-3)
  /// 0 = Unformed, 1 = Basic, 2 = Advanced, 3 = Ultimate
  @HiveField(3)
  int legsTier;

  /// Visual tier for head (0-3)
  /// 0 = Unformed, 1 = Basic, 2 = Advanced, 3 = Ultimate
  @HiveField(4)
  int headTier;

  /// Visual tier for arms (0-3)
  /// 0 = Unformed, 1 = Basic, 2 = Advanced, 3 = Ultimate
  @HiveField(5)
  int armsTier;

  /// Timestamp when the creature was first created
  @HiveField(6)
  DateTime createdAt;

  /// Timestamp of last modification
  @HiveField(7)
  DateTime lastUpdated;

  /// Optional user-given name for the creature
  @HiveField(8)
  String creatureName;

  CreatureState({
    this.xpVitality = 0,
    this.xpMind = 0,
    this.xpSoul = 0,
    this.legsTier = 0,
    this.headTier = 0,
    this.armsTier = 0,
    required this.createdAt,
    required this.lastUpdated,
    this.creatureName = 'The Mimic',
  });

  /// Factory constructor to create a fresh creature
  factory CreatureState.initial() {
    final now = DateTime.now();
    return CreatureState(
      createdAt: now,
      lastUpdated: now,
    );
  }

  // Helper getters for XP progress (0.0 - 1.0)

  /// Calculate Vitality XP progress within current tier (for shader glow)
  double get vitalityProgress =>
      XpConstants.calculateProgress(xpVitality, legsTier);

  /// Calculate Mind XP progress within current tier (for shader glow)
  double get mindProgress => XpConstants.calculateProgress(xpMind, headTier);

  /// Calculate Soul XP progress within current tier (for shader glow)
  double get soulProgress => XpConstants.calculateProgress(xpSoul, armsTier);

  /// Get total XP across all attributes
  int get totalXP => xpVitality + xpMind + xpSoul;

  /// Get average tier level (for overall progression indicator)
  double get averageTier => (legsTier + headTier + armsTier) / 3.0;

  /// Check if creature is at max evolution (all tiers at 3)
  bool get isFullyEvolved => legsTier == 3 && headTier == 3 && armsTier == 3;

  /// Copy with method for immutable updates
  CreatureState copyWith({
    int? xpVitality,
    int? xpMind,
    int? xpSoul,
    int? legsTier,
    int? headTier,
    int? armsTier,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? creatureName,
  }) {
    return CreatureState(
      xpVitality: xpVitality ?? this.xpVitality,
      xpMind: xpMind ?? this.xpMind,
      xpSoul: xpSoul ?? this.xpSoul,
      legsTier: legsTier ?? this.legsTier,
      headTier: headTier ?? this.headTier,
      armsTier: armsTier ?? this.armsTier,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      creatureName: creatureName ?? this.creatureName,
    );
  }

  @override
  String toString() {
    return 'CreatureState(name: $creatureName, '
        'XP: V:$xpVitality M:$xpMind S:$xpSoul, '
        'Tiers: L:$legsTier H:$headTier A:$armsTier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreatureState &&
        other.xpVitality == xpVitality &&
        other.xpMind == xpMind &&
        other.xpSoul == xpSoul &&
        other.legsTier == legsTier &&
        other.headTier == headTier &&
        other.armsTier == armsTier &&
        other.creatureName == creatureName;
  }

  @override
  int get hashCode {
    return Object.hash(
      xpVitality,
      xpMind,
      xpSoul,
      legsTier,
      headTier,
      armsTier,
      creatureName,
    );
  }
}
