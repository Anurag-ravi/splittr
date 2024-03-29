// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tripuser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripUserAdapter extends TypeAdapter<TripUser> {
  @override
  final int typeId = 1;

  @override
  TripUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripUser(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TripUser obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trip)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.dp)
      ..writeByte(5)
      ..write(obj.involved);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
