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
      profile: (fields[2] as List?)?.cast<Profile>(),
    );
  }

  @override
  void write(BinaryWriter writer, NativeItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bottom)
      ..writeByte(1)
      ..write(obj.side)
      ..writeByte(2)
      ..write(obj.profile);
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
      menuIcon: fields[4] is String ? fields[4] as String? : null,
      subList: (fields[5] as List?)?.cast<SubItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Side obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.uRL)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.menuIcon)
      ..writeByte(5)
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
      menuIcon: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubItem obj) {
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
      ..write(obj.menuIcon);
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

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 4;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      title: fields[0] as String?,
      icon: fields[1] as String?,
      uRL: fields[2] as String?,
      id: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
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
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
