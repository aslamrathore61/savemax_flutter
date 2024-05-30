// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 5;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfo(
      userId: fields[0] as int?,
      agentId: fields[1] as String?,
      name: fields[2] as String?,
      token: fields[3] as String?,
      status: fields[4] as bool?,
      userType: fields[5] as String?,
      loginStatus: fields[6] as int?,
      myEventsFlag: fields[7] as bool?,
      rwrflag: fields[8] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.agentId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.token)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.userType)
      ..writeByte(6)
      ..write(obj.loginStatus)
      ..writeByte(7)
      ..write(obj.myEventsFlag)
      ..writeByte(8)
      ..write(obj.rwrflag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
