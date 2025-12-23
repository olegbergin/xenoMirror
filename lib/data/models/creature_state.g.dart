// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creature_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatureStateAdapter extends TypeAdapter<CreatureState> {
  @override
  final int typeId = 0;

  @override
  CreatureState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatureState(
      xpVitality: fields[0] as int,
      xpMind: fields[1] as int,
      xpSoul: fields[2] as int,
      legsTier: fields[3] as int,
      headTier: fields[4] as int,
      armsTier: fields[5] as int,
      createdAt: fields[6] as DateTime,
      lastUpdated: fields[7] as DateTime,
      creatureName: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CreatureState obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.xpVitality)
      ..writeByte(1)
      ..write(obj.xpMind)
      ..writeByte(2)
      ..write(obj.xpSoul)
      ..writeByte(3)
      ..write(obj.legsTier)
      ..writeByte(4)
      ..write(obj.headTier)
      ..writeByte(5)
      ..write(obj.armsTier)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.creatureName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatureStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
