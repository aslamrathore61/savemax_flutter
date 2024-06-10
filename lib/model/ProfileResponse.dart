class ProfileResponse {
  int? userId;
  String? name;
  String? emailId;
  int? mobileNumber;
  String? imageUrl;
  String? countryCode;
  String? registerDateTime;
  String? language;
  bool? emailVerfication;
  bool? mobileVerfication;
  bool? reciveMarketingCommunications;
  bool? signInWithSocialMedia;
  bool? editMobileNumber;
  bool? editEmailId;
  bool? havePassword;
  bool? myEventsFlag;
  int? secondaryMobileNumber;
  Null? secondaryEmailId;
  Null? secondaryCountryCode;
  bool? seoDashboardFlag;
  bool? openHouseAdminFlag;
  List<Goingto>? goingto;
  List<Null>? interestedIn;
  List<Null>? notificationForCommunity;
  bool? rwrflag;
  String? flutter;

  ProfileResponse(
      {this.userId,
        this.name,
        this.emailId,
        this.mobileNumber,
        this.imageUrl,
        this.countryCode,
        this.registerDateTime,
        this.language,
        this.emailVerfication,
        this.mobileVerfication,
        this.reciveMarketingCommunications,
        this.signInWithSocialMedia,
        this.editMobileNumber,
        this.editEmailId,
        this.havePassword,
        this.myEventsFlag,
        this.secondaryMobileNumber,
        this.secondaryEmailId,
        this.secondaryCountryCode,
        this.seoDashboardFlag,
        this.openHouseAdminFlag,
        this.goingto,
        this.interestedIn,
        this.notificationForCommunity,
        this.rwrflag,
        this.flutter});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    emailId = json['emailId'];
    mobileNumber = json['mobileNumber'];
    imageUrl = json['imageUrl'];
    countryCode = json['countryCode'];
    registerDateTime = json['registerDateTime'];
    language = json['language'];
    emailVerfication = json['emailVerfication'];
    mobileVerfication = json['mobileVerfication'];
    reciveMarketingCommunications = json['reciveMarketingCommunications'];
    signInWithSocialMedia = json['signInWithSocialMedia'];
    editMobileNumber = json['editMobileNumber'];
    editEmailId = json['editEmailId'];
    havePassword = json['havePassword'];
    myEventsFlag = json['myEventsFlag'];
    secondaryMobileNumber = json['secondaryMobileNumber'];
    secondaryEmailId = json['secondaryEmailId'];
    secondaryCountryCode = json['secondaryCountryCode'];
    seoDashboardFlag = json['seoDashboardFlag'];
    openHouseAdminFlag = json['openHouseAdminFlag'];
    if (json['goingto'] != null) {
      goingto = <Goingto>[];
      json['goingto'].forEach((v) {
        goingto!.add(new Goingto.fromJson(v));
      });
    }
    // if (json['interestedIn'] != null) {
    //   interestedIn = <Null>[];
    //   json['interestedIn'].forEach((v) {
    //     interestedIn!.add(Null.fromJson(v));
    //   });
    // }
    // if (json['notificationForCommunity'] != null) {
    //   notificationForCommunity = <Null>[];
    //   json['notificationForCommunity'].forEach((v) {
    //     notificationForCommunity!.add(new Null.fromJson(v));
    //   });
    // }
    rwrflag = json['rwrflag'];
    flutter = json['flutter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['emailId'] = this.emailId;
    data['mobileNumber'] = this.mobileNumber;
    data['imageUrl'] = this.imageUrl;
    data['countryCode'] = this.countryCode;
    data['registerDateTime'] = this.registerDateTime;
    data['language'] = this.language;
    data['emailVerfication'] = this.emailVerfication;
    data['mobileVerfication'] = this.mobileVerfication;
    data['reciveMarketingCommunications'] = this.reciveMarketingCommunications;
    data['signInWithSocialMedia'] = this.signInWithSocialMedia;
    data['editMobileNumber'] = this.editMobileNumber;
    data['editEmailId'] = this.editEmailId;
    data['havePassword'] = this.havePassword;
    data['myEventsFlag'] = this.myEventsFlag;
    data['secondaryMobileNumber'] = this.secondaryMobileNumber;
    data['secondaryEmailId'] = this.secondaryEmailId;
    data['secondaryCountryCode'] = this.secondaryCountryCode;
    data['seoDashboardFlag'] = this.seoDashboardFlag;
    data['openHouseAdminFlag'] = this.openHouseAdminFlag;
    if (this.goingto != null) {
      data['goingto'] = this.goingto!.map((v) => v.toJson()).toList();
    }
    // if (this.interestedIn != null) {
    //   data['interestedIn'] = this.interestedIn!.map((v) => v.toJson()).toList();
    // }
    // if (this.notificationForCommunity != null) {
    //   data['notificationForCommunity'] =
    //       this.notificationForCommunity!.map((v) => v.toJson()).toList();
    // }
    data['rwrflag'] = this.rwrflag;
    data['flutter'] = this.flutter;
    return data;
  }
}

class Goingto {
  int? id;
  String? value;
  bool? status;

  Goingto({this.id, this.value, this.status});

  Goingto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    data['status'] = this.status;
    return data;
  }
}