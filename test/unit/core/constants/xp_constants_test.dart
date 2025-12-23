import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/core/constants/xp_constants.dart';

void main() {
  group('XpConstants', () {
    group('getTierForXP', () {
      test('returns tier 0 for XP below tier 1 threshold', () {
        expect(XpConstants.getTierForXP(0), 0);
        expect(XpConstants.getTierForXP(99), 0);
      });

      test('returns tier 1 for XP at tier 1 threshold', () {
        expect(XpConstants.getTierForXP(100), 1);
        expect(XpConstants.getTierForXP(200), 1);
      });

      test('returns tier 2 for XP at tier 2 threshold', () {
        expect(XpConstants.getTierForXP(400), 2);
        expect(XpConstants.getTierForXP(600), 2);
      });

      test('returns tier 3 for XP at tier 3 threshold', () {
        expect(XpConstants.getTierForXP(1000), 3);
        expect(XpConstants.getTierForXP(9999), 3);
      });

      test('handles boundary conditions correctly', () {
        expect(XpConstants.getTierForXP(99), 0);
        expect(XpConstants.getTierForXP(100), 1);
        expect(XpConstants.getTierForXP(399), 1);
        expect(XpConstants.getTierForXP(400), 2);
        expect(XpConstants.getTierForXP(999), 2);
        expect(XpConstants.getTierForXP(1000), 3);
      });
    });

    group('calculateProgress', () {
      test('returns 0.0 at start of tier', () {
        expect(XpConstants.calculateProgress(0, 0), 0.0);
        expect(XpConstants.calculateProgress(100, 1), 0.0);
        expect(XpConstants.calculateProgress(400, 2), 0.0);
      });

      test('returns 0.5 at midpoint of tier', () {
        // Tier 0: 0-100 XP, midpoint = 50
        expect(XpConstants.calculateProgress(50, 0), 0.5);

        // Tier 1: 100-400 XP (300 range), midpoint = 250
        expect(XpConstants.calculateProgress(250, 1), closeTo(0.5, 0.01));

        // Tier 2: 400-1000 XP (600 range), midpoint = 700
        expect(XpConstants.calculateProgress(700, 2), closeTo(0.5, 0.01));
      });

      test('returns 1.0 at tier threshold', () {
        expect(XpConstants.calculateProgress(100, 0), 1.0);
        expect(XpConstants.calculateProgress(400, 1), 1.0);
        expect(XpConstants.calculateProgress(1000, 2), 1.0);
      });

      test('clamps progress to 1.0 if exceeding threshold', () {
        expect(XpConstants.calculateProgress(500, 0), 1.0);
        expect(XpConstants.calculateProgress(9999, 2), 1.0);
      });

      test('clamps progress to 0.0 if below tier start', () {
        // Edge case: shouldn't happen in practice but test defensive code
        expect(XpConstants.calculateProgress(50, 1), 0.0);
      });
    });

    group('getActivityXP', () {
      test('returns correct XP for known activities', () {
        expect(XpConstants.getActivityXP('squats'), 10);
        expect(XpConstants.getActivityXP('pushups'), 12);
        expect(XpConstants.getActivityXP('reading'), 15);
        expect(XpConstants.getActivityXP('meditation'), 10);
      });

      test('is case-insensitive', () {
        expect(XpConstants.getActivityXP('SQUATS'), 10);
        expect(XpConstants.getActivityXP('Squats'), 10);
        expect(XpConstants.getActivityXP('sQuAtS'), 10);
      });

      test('returns default XP for unknown activities', () {
        expect(XpConstants.getActivityXP('unknown'), 10);
        expect(XpConstants.getActivityXP('unknown', defaultXP: 5), 5);
      });
    });

    group('calculateFinalXP', () {
      test('returns base XP without bonuses', () {
        expect(XpConstants.calculateFinalXP(10), 10);
        expect(XpConstants.calculateFinalXP(20), 20);
      });

      test('applies camera validation bonus', () {
        expect(
          XpConstants.calculateFinalXP(10, cameraValidated: true),
          15,  // 10 * 1.5
        );
      });

      test('applies streak bonus', () {
        expect(
          XpConstants.calculateFinalXP(10, hasStreak: true),
          12,  // 10 * 1.2
        );
      });

      test('stacks multiple bonuses multiplicatively', () {
        expect(
          XpConstants.calculateFinalXP(
            10,
            cameraValidated: true,
            hasStreak: true,
          ),
          18,  // 10 * 1.5 * 1.2 = 18
        );
      });

      test('rounds fractional XP correctly', () {
        expect(
          XpConstants.calculateFinalXP(7, cameraValidated: true),
          11,  // 7 * 1.5 = 10.5, rounds to 11
        );
      });
    });
  });

  group('XpThresholds', () {
    test('forTier returns correct thresholds for tier 0', () {
      final thresholds = XpThresholds.forTier(0);
      expect(thresholds.tier, 0);
      expect(thresholds.currentTierXp, 0);
      expect(thresholds.nextTierXp, 100);
      expect(thresholds.tierRange, 100);
      expect(thresholds.isMaxTier, false);
    });

    test('forTier returns correct thresholds for tier 1', () {
      final thresholds = XpThresholds.forTier(1);
      expect(thresholds.tier, 1);
      expect(thresholds.currentTierXp, 100);
      expect(thresholds.nextTierXp, 400);
      expect(thresholds.tierRange, 300);
      expect(thresholds.isMaxTier, false);
    });

    test('forTier returns correct thresholds for tier 2', () {
      final thresholds = XpThresholds.forTier(2);
      expect(thresholds.tier, 2);
      expect(thresholds.currentTierXp, 400);
      expect(thresholds.nextTierXp, 1000);
      expect(thresholds.tierRange, 600);
      expect(thresholds.isMaxTier, false);
    });

    test('forTier returns correct thresholds for tier 3 (max)', () {
      final thresholds = XpThresholds.forTier(3);
      expect(thresholds.tier, 3);
      expect(thresholds.currentTierXp, 1000);
      expect(thresholds.nextTierXp, 9999);
      expect(thresholds.tierRange, 8999);
      expect(thresholds.isMaxTier, true);
    });

    test('forTier handles invalid tier (defaults to 0)', () {
      final thresholds = XpThresholds.forTier(-1);
      expect(thresholds.tier, 0);

      final thresholdsHigh = XpThresholds.forTier(99);
      expect(thresholdsHigh.tier, 0);
    });
  });
}
