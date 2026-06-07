// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitEntryModelAdapter extends TypeAdapter<SplitEntryModel> {
  @override
  final int typeId = 4;

  @override
  SplitEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitEntryModel(
      user: fields[0] as String,
      amount: fields[1] as double,
      shareOrPercent: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SplitEntryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.shareOrPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SplitEntryModelImpl _$$SplitEntryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SplitEntryModelImpl(
      user: json['user'] as String,
      amount: (json['amount'] as num).toDouble(),
      shareOrPercent: (json['share_or_percent'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$SplitEntryModelImplToJson(
        _$SplitEntryModelImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'amount': instance.amount,
      'share_or_percent': instance.shareOrPercent,
    };
