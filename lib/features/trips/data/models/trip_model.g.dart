// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

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
      id: fields[1] as String,
      name: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShortTripModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.name);
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
      id: fields[0] as String,
      code: fields[1] as String,
      name: fields[2] as String,
      created: fields[3] as DateTime,
      currency: fields[4] as String,
      createdBy: fields[5] as String,
      users: (fields[6] as List).cast<TripMemberModel>(),
      expenses: (fields[7] as List).cast<ExpenseModel>(),
      payments: (fields[8] as List).cast<PaymentModel>(),
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
      ..write(obj.createdBy)
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShortTripModelImpl _$$ShortTripModelImplFromJson(Map<String, dynamic> json) =>
    _$ShortTripModelImpl(
      id: json['_id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$ShortTripModelImplToJson(
        _$ShortTripModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
    };

_$TripModelImpl _$$TripModelImplFromJson(Map<String, dynamic> json) =>
    _$TripModelImpl(
      id: json['_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      created: DateTime.parse(json['created'] as String),
      currency: json['currency'] as String,
      createdBy: json['created_by'] as String,
      users: (json['users'] as List<dynamic>)
          .map((e) => TripMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TripModelImplToJson(_$TripModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'created': instance.created.toIso8601String(),
      'currency': instance.currency,
      'created_by': instance.createdBy,
      'users': instance.users,
      'expenses': instance.expenses,
      'payments': instance.payments,
    };
