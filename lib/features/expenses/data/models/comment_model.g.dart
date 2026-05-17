// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

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
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      trip: fields[3] as String,
      type: fields[4] as String,
      title: fields[5] as String,
      body: fields[6] as String,
      createdAt: fields[7] as DateTime,
      createdById: fields[8] as String,
      createdByUser: fields[9] as String,
      createdByName: fields[10] as String,
      createdByDp: fields[11] as String,
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
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.trip)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.body)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.createdById)
      ..writeByte(9)
      ..write(obj.createdByUser)
      ..writeByte(10)
      ..write(obj.createdByName)
      ..writeByte(11)
      ..write(obj.createdByDp)
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
