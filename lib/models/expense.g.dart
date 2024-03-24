// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

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
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as double,
      fields[4] as String,
      fields[5] as splitTypeEnum,
      fields[6] as DateTime,
      (fields[7] as List).cast<By>(),
      (fields[8] as List).cast<By>(),
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
      ..write(obj.paid_by)
      ..writeByte(8)
      ..write(obj.paid_for);
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

class ByAdapter extends TypeAdapter<By> {
  @override
  final int typeId = 4;

  @override
  By read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return By(
      fields[0] as String,
      fields[1] as double,
      fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, By obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.share_or_percent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ByAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class splitTypeEnumAdapter extends TypeAdapter<splitTypeEnum> {
  @override
  final int typeId = 3;

  @override
  splitTypeEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return splitTypeEnum.equal;
      case 1:
        return splitTypeEnum.unequal;
      case 2:
        return splitTypeEnum.shares;
      case 3:
        return splitTypeEnum.percent;
      default:
        return splitTypeEnum.equal;
    }
  }

  @override
  void write(BinaryWriter writer, splitTypeEnum obj) {
    switch (obj) {
      case splitTypeEnum.equal:
        writer.writeByte(0);
        break;
      case splitTypeEnum.unequal:
        writer.writeByte(1);
        break;
      case splitTypeEnum.shares:
        writer.writeByte(2);
        break;
      case splitTypeEnum.percent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is splitTypeEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
