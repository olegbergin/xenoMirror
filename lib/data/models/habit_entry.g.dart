// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEntryAdapter extends TypeAdapter<HabitEntry> {
  @override
  final int typeId = 1;

  @override
  HabitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEntry(
      id: fields[0] as String,
      habitType: fields[1] as HabitType,
      activity: fields[2] as String,
      xpEarned: fields[3] as int,
      timestamp: fields[4] as DateTime,
      validationMethod: fields[5] as ValidationMethod,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitType)
      ..writeByte(2)
      ..write(obj.activity)
      ..writeByte(3)
      ..write(obj.xpEarned)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.validationMethod)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 2;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.vitality;
      case 1:
        return HabitType.mind;
      case 2:
        return HabitType.soul;
      default:
        return HabitType.vitality;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.vitality:
        writer.writeByte(0);
        break;
      case HabitType.mind:
        writer.writeByte(1);
        break;
      case HabitType.soul:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ValidationMethodAdapter extends TypeAdapter<ValidationMethod> {
  @override
  final int typeId = 3;

  @override
  ValidationMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ValidationMethod.manual;
      case 1:
        return ValidationMethod.camera;
      default:
        return ValidationMethod.manual;
    }
  }

  @override
  void write(BinaryWriter writer, ValidationMethod obj) {
    switch (obj) {
      case ValidationMethod.manual:
        writer.writeByte(0);
        break;
      case ValidationMethod.camera:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
