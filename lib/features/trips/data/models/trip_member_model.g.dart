// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripMemberModelAdapter extends TypeAdapter<TripMemberModel> {
  @override
  final int typeId = 1;

  @override
  TripMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripMemberModel(
      id: fields[0] as String,
      trip: fields[1] as String,
      user: fields[2] as String,
      name: fields[3] as String,
      dp: fields[4] as String,
      involved: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TripMemberModel obj) {
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
      other is TripMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripMemberModelImpl _$$TripMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TripMemberModelImpl(
      id: json['_id'] as String,
      trip: json['trip'] as String,
      user: json['user'] as String,
      name: json['name'] as String,
      dp: json['dp'] as String,
      involved: json['involved'] as bool,
    );

Map<String, dynamic> _$$TripMemberModelImplToJson(
        _$TripMemberModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'trip': instance.trip,
      'user': instance.user,
      'name': instance.name,
      'dp': instance.dp,
      'involved': instance.involved,
    };
