// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerProfileAdapter extends TypeAdapter<PlayerProfile> {
  @override
  final int typeId = 0;

  @override
  PlayerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProfile(
      level: fields[0] as int,
      xp: fields[1] as int,
      xpForNextLevel: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      lastPlayed: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.xp)
      ..writeByte(2)
      ..write(obj.xpForNextLevel)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastPlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
