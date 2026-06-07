// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 2;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      trip: fields[1] as String,
      amount: fields[2] as double,
      created: fields[3] as DateTime,
      by: fields[4] as String,
      to: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trip)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.by)
      ..writeByte(5)
      ..write(obj.to);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentModelImpl _$$PaymentModelImplFromJson(Map<String, dynamic> json) =>
    _$PaymentModelImpl(
      id: json['_id'] as String,
      trip: json['trip'] as String,
      amount: (json['amount'] as num).toDouble(),
      created: DateTime.parse(json['created'] as String),
      by: json['by'] as String,
      to: json['to'] as String,
    );

Map<String, dynamic> _$$PaymentModelImplToJson(_$PaymentModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'trip': instance.trip,
      'amount': instance.amount,
      'created': instance.created.toIso8601String(),
      'by': instance.by,
      'to': instance.to,
    };
