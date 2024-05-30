import 'package:hive/hive.dart';

part 'user_info.g.dart';

@HiveType(typeId: 5)
class UserInfo extends HiveObject {
  @HiveField(0)
  int? userId;

  @HiveField(1)
  String? agentId;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String? token;

  @HiveField(4)
  bool? status;

  @HiveField(5)
  String? userType;

  @HiveField(6)
  int? loginStatus;

  @HiveField(7)
  bool? myEventsFlag;

  @HiveField(8)
  bool? rwrflag;

  UserInfo({
    this.userId,
    this.agentId,
    this.name,
    this.token,
    this.status,
    this.userType,
    this.loginStatus,
    this.myEventsFlag,
    this.rwrflag,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      agentId: json['agentId'],
      name: json['name'],
      token: json['token'],
      status: json['status'],
      userType: json['userType'],
      loginStatus: json['loginStatus'],
      myEventsFlag: json['myEventsFlag'],
      rwrflag: json['rwrflag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'agentId': agentId,
      'name': name,
      'token': token,
      'status': status,
      'userType': userType,
      'loginStatus': loginStatus,
      'myEventsFlag': myEventsFlag,
      'rwrflag': rwrflag,
    };
  }
}
