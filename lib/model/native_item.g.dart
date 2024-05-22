// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NativeItemAdapter extends TypeAdapter<NativeItem> {
  @override
  final int typeId = 0;

  @override
  NativeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NativeItem(
      bottom: (fields[0] as List?)?.cast<Bottom>(),
      side: (fields[1] as List?)?.cast<Side>(),
    );
  }

  @override
  void write(BinaryWriter writer, NativeItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.bottom)
      ..writeByte(1)
      ..write(obj.side);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NativeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BottomAdapter extends TypeAdapter<Bottom> {
  @override
  final int typeId = 1;

  @override
  Bottom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bottom(
      title: fields[0] as String?,
      icon: fields[1] as String?,
      uRL: fields[2] as String?,
      id: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Bottom obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.uRL)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SideAdapter extends TypeAdapter<Side> {
  @override
  final int typeId = 2;

  @override
  Side read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Side(
      title: fields[0] as String?,
      icon: fields[1] as String?,
      uRL: fields[2] as String?,
      id: fields[3] as String?,
      subList: (fields[4] as List?)?.cast<SubItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Side obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.uRL)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.subList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubItemAdapter extends TypeAdapter<SubItem> {
  @override
  final int typeId = 3;

  @override
  SubItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubItem(
      title: fields[0] as String?,
      icon: fields[1] as String?,
      uRL: fields[2] as String?,
      id: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.uRL)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
