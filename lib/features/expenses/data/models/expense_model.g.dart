// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 5;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      trip: fields[1] as String,
      name: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as String,
      splitType: fields[5] as String,
      created: fields[6] as DateTime,
      paidBy: (fields[7] as List).cast<SplitEntryModel>(),
      paidFor: (fields[8] as List).cast<SplitEntryModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trip)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.splitType)
      ..writeByte(6)
      ..write(obj.created)
      ..writeByte(7)
      ..write(obj.paidBy)
      ..writeByte(8)
      ..write(obj.paidFor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseModelImpl _$$ExpenseModelImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseModelImpl(
      id: json['_id'] as String,
      trip: json['trip'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      splitType: json['split_type'] as String,
      created: DateTime.parse(json['created'] as String),
      paidBy: (json['paid_by'] as List<dynamic>)
          .map((e) => SplitEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paidFor: (json['paid_for'] as List<dynamic>)
          .map((e) => SplitEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ExpenseModelImplToJson(_$ExpenseModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'trip': instance.trip,
      'name': instance.name,
      'amount': instance.amount,
      'category': instance.category,
      'split_type': instance.splitType,
      'created': instance.created.toIso8601String(),
      'paid_by': instance.paidBy,
      'paid_for': instance.paidFor,
    };
