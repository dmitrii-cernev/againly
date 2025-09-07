// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceConfigAdapter extends TypeAdapter<RecurrenceConfig> {
  @override
  final int typeId = 4;

  @override
  RecurrenceConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurrenceConfig(
      unit: fields[0] as RecurrenceUnit,
      interval: fields[1] as int,
      resetTimeHour: fields[2] as int?,
      resetTimeMinute: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurrenceConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.unit)
      ..writeByte(1)
      ..write(obj.interval)
      ..writeByte(2)
      ..write(obj.resetTimeHour)
      ..writeByte(3)
      ..write(obj.resetTimeMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceUnitAdapter extends TypeAdapter<RecurrenceUnit> {
  @override
  final int typeId = 3;

  @override
  RecurrenceUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceUnit.none;
      case 1:
        return RecurrenceUnit.minutes;
      case 2:
        return RecurrenceUnit.hours;
      case 3:
        return RecurrenceUnit.days;
      case 4:
        return RecurrenceUnit.weeks;
      case 5:
        return RecurrenceUnit.months;
      default:
        return RecurrenceUnit.none;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceUnit obj) {
    switch (obj) {
      case RecurrenceUnit.none:
        writer.writeByte(0);
        break;
      case RecurrenceUnit.minutes:
        writer.writeByte(1);
        break;
      case RecurrenceUnit.hours:
        writer.writeByte(2);
        break;
      case RecurrenceUnit.days:
        writer.writeByte(3);
        break;
      case RecurrenceUnit.weeks:
        writer.writeByte(4);
        break;
      case RecurrenceUnit.months:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
