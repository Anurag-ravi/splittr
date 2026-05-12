// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommentModelAdapter extends TypeAdapter<CommentModel> {
  @override
  final int typeId = 8;

  @override
  CommentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommentModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as DateTime,
      fields[8] as String,
      fields[9] as String,
      fields[10] as String,
      fields[11] as String,
      diff: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CommentModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entity_type)
      ..writeByte(2)
      ..write(obj.entity_id)
      ..writeByte(3)
      ..write(obj.trip)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.body_text)
      ..writeByte(7)
      ..write(obj.created_at)
      ..writeByte(8)
      ..write(obj.created_by_id)
      ..writeByte(9)
      ..write(obj.created_by_user)
      ..writeByte(10)
      ..write(obj.created_by_name)
      ..writeByte(11)
      ..write(obj.created_by_dp)
      ..writeByte(12)
      ..write(obj.diff);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
