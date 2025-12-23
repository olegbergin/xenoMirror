import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/data/models/creature_state.dart';

void main() {
  group('CreatureState', () {
    test('initial() creates state with zero XP and tier 0', () {
      final state = CreatureState.initial();

      expect(state.xpVitality, 0);
      expect(state.xpMind, 0);
      expect(state.xpSoul, 0);
      expect(state.legsTier, 0);
      expect(state.headTier, 0);
      expect(state.armsTier, 0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = CreatureState.initial();
      final updated = original.copyWith(
        xpVitality: 100,
        legsTier: 1,
      );

      expect(updated.xpVitality, 100);
      expect(updated.legsTier, 1);
      expect(updated.xpMind, 0);  // Unchanged
      expect(updated.xpSoul, 0);  // Unchanged
    });

    test('copyWith preserves unchanged values', () {
      final original = CreatureState.initial().copyWith(
        xpVitality: 50,
        xpMind: 30,
        xpSoul: 20,
        legsTier: 0,
        headTier: 0,
        armsTier: 0,
      );

      final updated = original.copyWith(xpVitality: 100);

      expect(updated.xpVitality, 100);  // Changed
      expect(updated.xpMind, 30);       // Unchanged
      expect(updated.xpSoul, 20);       // Unchanged
      expect(updated.legsTier, 0);      // Unchanged
    });

    test('equality works correctly', () {
      final state1 = CreatureState.initial();
      final state2 = CreatureState.initial();
      final state3 = state1.copyWith(xpVitality: 50);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('equality compares all fields', () {
      final state1 = CreatureState.initial().copyWith(xpVitality: 100);
      final state2 = CreatureState.initial().copyWith(xpVitality: 100);
      final state3 = CreatureState.initial().copyWith(xpVitality: 101);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('progress getters return correct values', () {
      final state = CreatureState.initial().copyWith(
        xpVitality: 50,  // 50% of tier 0 (0-100)
        xpMind: 100,     // 0% of tier 1 (100-400)
        xpSoul: 700,     // 50% of tier 2 (400-1000)
        legsTier: 0,
        headTier: 1,
        armsTier: 2,
      );

      expect(state.vitalityProgress, 0.5);
      expect(state.mindProgress, 0.0);
      expect(state.soulProgress, closeTo(0.5, 0.01));
    });

    test('progress getters handle tier boundaries', () {
      final state = CreatureState.initial().copyWith(
        xpVitality: 100,  // Exactly at tier 1 threshold (100% of tier 0)
        xpMind: 400,      // Exactly at tier 2 threshold (100% of tier 1)
        xpSoul: 1000,     // Exactly at tier 3 threshold (100% of tier 2)
        legsTier: 0,
        headTier: 1,
        armsTier: 2,
      );

      expect(state.vitalityProgress, 1.0);
      expect(state.mindProgress, 1.0);
      expect(state.soulProgress, 1.0);
    });

    test('progress getters clamp to 1.0 if exceeding threshold', () {
      final state = CreatureState.initial().copyWith(
        xpVitality: 500,  // Way over tier 0 threshold
        legsTier: 0,
      );

      expect(state.vitalityProgress, 1.0);  // Clamped
    });

    test('lastUpdated is preserved in copyWith', () {
      final now = DateTime(2025, 12, 23, 12, 0, 0);
      final original = CreatureState.initial().copyWith(lastUpdated: now);
      final updated = original.copyWith(xpVitality: 50);

      expect(updated.lastUpdated, now);
    });
  });
}
