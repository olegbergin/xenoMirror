import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:client_app/data/models/creature_state.dart';
import 'package:client_app/data/models/habit_entry.dart';

/// Service for communicating with Unity creature renderer
///
/// This service provides a clean API for sending messages to Unity.
/// All creature visual updates go through this service.
///
/// Unity GameObject: "CreatureController" (must exist in Unity scene)
/// Unity Script: CreatureController.cs (with public methods matching message names)
///
/// Message Protocol:
/// - OnReaction: Trigger visual feedback when XP added (attribute: 'vitality'|'mind'|'soul')
/// - OnEvolution: Trigger tier-up animation (format: 'legs:2', 'head:3', etc.)
/// - OnStateUpdate: Sync XP progress for shader glow (format: '0.5,0.8,0.3' CSV)
class UnityBridgeService {
  UnityBridgeService({
    required UnityWidgetController controller,
  }) : _controller = controller;

  final UnityWidgetController _controller;

  /// Name of the Unity GameObject that receives messages
  static const String _gameObjectName = 'CreatureController';

  /// Send a reaction trigger to Unity
  ///
  /// Causes the creature to glow/pulse in the attribute's color.
  /// Used immediately after habit logging for visual feedback.
  ///
  /// Example:
  /// ```dart
  /// bridgeService.sendReaction(HabitType.vitality);
  /// ```
  ///
  /// Unity receives: OnReaction("vitality")
  void sendReaction(HabitType habitType) {
    final attributeName = habitType.name; // 'vitality', 'mind', or 'soul'

    try {
      _controller.postMessage(
        _gameObjectName,
        'OnReaction',
        attributeName,
      );
    } catch (e) {
      print('UnityBridgeService: Failed to send reaction: $e');
    }
  }

  /// Send an evolution event to Unity
  ///
  /// Triggers a tier-up animation and material swap for a body part.
  /// Used when creature crosses an XP tier threshold.
  ///
  /// Example:
  /// ```dart
  /// bridgeService.sendEvolution('legs', 2);
  /// ```
  ///
  /// Unity receives: OnEvolution("legs:2")
  void sendEvolution(String bodyPart, int newTier) {
    final message = '$bodyPart:$newTier'; // e.g., "legs:2"

    try {
      _controller.postMessage(
        _gameObjectName,
        'OnEvolution',
        message,
      );
    } catch (e) {
      print('UnityBridgeService: Failed to send evolution: $e');
    }
  }

  /// Send complete creature state update to Unity
  ///
  /// Syncs all XP progress values for shader glow intensity.
  /// Used on app start and after major state changes.
  ///
  /// Example:
  /// ```dart
  /// bridgeService.sendStateUpdate(creatureState);
  /// ```
  ///
  /// Unity receives: OnStateUpdate("0.5,0.8,0.3")
  /// Format: vitalityProgress,mindProgress,soulProgress (CSV)
  void sendStateUpdate(CreatureState creature) {
    // Format progress values as CSV (0.0-1.0 range)
    final message = '${creature.vitalityProgress.toStringAsFixed(2)},'
        '${creature.mindProgress.toStringAsFixed(2)},'
        '${creature.soulProgress.toStringAsFixed(2)}';

    try {
      _controller.postMessage(
        _gameObjectName,
        'OnStateUpdate',
        message,
      );
    } catch (e) {
      print('UnityBridgeService: Failed to send state update: $e');
    }
  }

  /// Send tier values to Unity for visual tier synchronization
  ///
  /// Updates all body part tiers at once.
  /// Used on app start to ensure Unity matches stored state.
  ///
  /// Example:
  /// ```dart
  /// bridgeService.sendTierSync(creatureState);
  /// ```
  ///
  /// Unity receives: OnTierSync("legs:1,head:2,arms:0")
  void sendTierSync(CreatureState creature) {
    final message = 'legs:${creature.legsTier},'
        'head:${creature.headTier},'
        'arms:${creature.armsTier}';

    try {
      _controller.postMessage(
        _gameObjectName,
        'OnTierSync',
        message,
      );
    } catch (e) {
      print('UnityBridgeService: Failed to send tier sync: $e');
    }
  }

  /// Send custom message to Unity
  ///
  /// Low-level method for sending arbitrary messages.
  /// Use specific methods above when possible.
  void sendCustomMessage(String methodName, String message) {
    try {
      _controller.postMessage(
        _gameObjectName,
        methodName,
        message,
      );
    } catch (e) {
      print('UnityBridgeService: Failed to send custom message: $e');
    }
  }
}
