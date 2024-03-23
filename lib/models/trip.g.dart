// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShortTripModelAdapter extends TypeAdapter<ShortTripModel> {
  @override
  final int typeId = 6;

  @override
  ShortTripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShortTripModel(
      name: fields[0] as String,
      id: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShortTripModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortTripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 7;

  @override
  TripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as DateTime,
      fields[4] as String,
      fields[5] as String,
      (fields[6] as List).cast<TripUser>(),
      (fields[7] as List).cast<ExpenseModel>(),
      (fields[8] as List).cast<PaymentModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.created_by)
      ..writeByte(6)
      ..write(obj.users)
      ..writeByte(7)
      ..write(obj.expenses)
      ..writeByte(8)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
