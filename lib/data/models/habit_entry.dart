import 'package:hive/hive.dart';

part 'habit_entry.g.dart';

/// Type of habit that determines which body part evolves.
///
/// - VITALITY: Sports, Sleep, Nutrition → Affects Legs & Core
/// - MIND: Reading, Study, Planning → Affects Head & Sensors
/// - SOUL: Hobbies, Art, Meditation → Affects Arms & Aura
@HiveType(typeId: 2)
enum HabitType {
  @HiveField(0)
  vitality,

  @HiveField(1)
  mind,

  @HiveField(2)
  soul,
}

/// Method used to validate the habit was completed.
///
/// - MANUAL: User manually logged the activity
/// - CAMERA: Validated using AI vision (ML Kit pose detection or image labeling)
@HiveType(typeId: 3)
enum ValidationMethod {
  @HiveField(0)
  manual,

  @HiveField(1)
  camera,
}

/// Represents a single habit log entry.
///
/// Each entry records when a user completed an activity,
/// what type of habit it was, how much XP was earned,
/// and how it was validated.
///
/// Stored in Hive as a list of entries (habit history).
@HiveType(typeId: 1)
class HabitEntry extends HiveObject {
  /// Unique identifier for this entry
  @HiveField(0)
  String id;

  /// Type of habit (determines which body part gains XP)
  @HiveField(1)
  HabitType habitType;

  /// Specific activity performed (e.g., 'squats', 'reading', 'meditation')
  @HiveField(2)
  String activity;

  /// XP awarded for this activity (after multipliers applied)
  @HiveField(3)
  int xpEarned;

  /// When this activity was logged
  @HiveField(4)
  DateTime timestamp;

  /// How the activity was validated
  @HiveField(5)
  ValidationMethod validationMethod;

  /// Optional metadata for additional context
  /// Examples:
  /// - { "reps": 20, "sets": 3 } for squats
  /// - { "duration_minutes": 15 } for reading
  /// - { "confidence": 0.95 } for camera validation
  @HiveField(6)
  Map<String, dynamic>? metadata;

  HabitEntry({
    required this.id,
    required this.habitType,
    required this.activity,
    required this.xpEarned,
    required this.timestamp,
    required this.validationMethod,
    this.metadata,
  });

  /// Factory constructor to create a new entry with current timestamp
  factory HabitEntry.create({
    required String id,
    required HabitType habitType,
    required String activity,
    required int xpEarned,
    required ValidationMethod validationMethod,
    Map<String, dynamic>? metadata,
  }) {
    return HabitEntry(
      id: id,
      habitType: habitType,
      activity: activity,
      xpEarned: xpEarned,
      timestamp: DateTime.now(),
      validationMethod: validationMethod,
      metadata: metadata,
    );
  }

  /// Check if this entry was validated by camera
  bool get isCameraValidated => validationMethod == ValidationMethod.camera;

  /// Check if this entry was manually logged
  bool get isManualLog => validationMethod == ValidationMethod.manual;

  /// Get a human-readable habit type label
  String get habitTypeLabel {
    switch (habitType) {
      case HabitType.vitality:
        return 'Vitality';
      case HabitType.mind:
        return 'Mind';
      case HabitType.soul:
        return 'Soul';
    }
  }

  /// Copy with method for immutable updates
  HabitEntry copyWith({
    String? id,
    HabitType? habitType,
    String? activity,
    int? xpEarned,
    DateTime? timestamp,
    ValidationMethod? validationMethod,
    Map<String, dynamic>? metadata,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitType: habitType ?? this.habitType,
      activity: activity ?? this.activity,
      xpEarned: xpEarned ?? this.xpEarned,
      timestamp: timestamp ?? this.timestamp,
      validationMethod: validationMethod ?? this.validationMethod,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'HabitEntry(id: $id, type: $habitTypeLabel, '
        'activity: $activity, xp: +$xpEarned, '
        'time: ${timestamp.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HabitEntry &&
        other.id == id &&
        other.habitType == habitType &&
        other.activity == activity &&
        other.xpEarned == xpEarned &&
        other.timestamp == timestamp &&
        other.validationMethod == validationMethod;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      habitType,
      activity,
      xpEarned,
      timestamp,
      validationMethod,
    );
  }
}

/// Extension methods for HabitType enum
extension HabitTypeExtension on HabitType {
  /// Get display name for this habit type
  String get displayName {
    switch (this) {
      case HabitType.vitality:
        return 'Vitality';
      case HabitType.mind:
        return 'Mind';
      case HabitType.soul:
        return 'Soul';
    }
  }

  /// Get description for this habit type
  String get description {
    switch (this) {
      case HabitType.vitality:
        return 'Sports, Sleep, Nutrition';
      case HabitType.mind:
        return 'Reading, Study, Planning';
      case HabitType.soul:
        return 'Hobbies, Art, Meditation';
    }
  }

  /// Get body part affected by this habit type
  String get affectedBodyPart {
    switch (this) {
      case HabitType.vitality:
        return 'Legs & Core';
      case HabitType.mind:
        return 'Head & Sensors';
      case HabitType.soul:
        return 'Arms & Aura';
    }
  }
}
