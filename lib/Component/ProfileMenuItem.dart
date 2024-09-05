
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:savemax_flutter/Config.dart';
import 'package:savemax_flutter/model/ProfileResponse.dart';

class ProfileMenuItem extends StatefulWidget {
  final ProfileResponse? profileResponse;
  final String userType;
  final String parenturl;
  final String parentID;
  final String title;
  final Function onTap;

  const ProfileMenuItem({
    Key? key,
    required this.profileResponse,
    required this.userType,
    required this.parenturl,
    required this.parentID,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ProfileMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<ProfileMenuItem> {
  List<String> openHouseAdminFlag = [
    Config.Open_House_Schedule,
    Config.Open_House_Availability,
  ];
  //Config.Open_House_Calender

  List<String> agentLoginvisiblity = [
    Config.Gamechanger,
    Config.Add_Assignment,
    Config.Agent_Dashboard,
    Config.Market_Place,
  ];

  List<String> userLoginvisiblity = [
    Config.View_Profile,
    Config.Favourites,
    Config.LOGOUT_ID,
  ];

  List<String> otherwillshowalways = [
    Config.View_Profile,
    Config.Add_Assignment,
    Config.Market_Place,
    Config.Favourites,
    Config.LOGOUT_ID,
  ];


  List<String> rwrCase = [
    Config.RWR_Events,
    Config.My_Events
  ];


  bool shouldShowRow() {
    print('profileResponse ${widget.profileResponse?.toJson()}');
    print('userTypeResponse ${widget.userType}');

    if (widget.userType == "user") {
      if(userLoginvisiblity.contains(widget.parentID)) {
        return false;
      }else {
        return true;
      }
    }



    if (widget.profileResponse?.openHouseAdminFlag == false &&
        openHouseAdminFlag.contains(widget.parentID)) {
      return true;
    }
    /*else if(widget.profileResponse.rwrflag == false && ) {

    }*/
    else if (widget.profileResponse?.openHouseAdminFlag == true && openHouseAdminFlag.contains(widget.parentID)) {
      return false;
    } else if (widget.profileResponse?.seoDashboardFlag == true && widget.parentID == Config.SEO_Details) {
      return false;
    }else if (widget.profileResponse?.rwrflag == true && rwrCase.contains(widget.parentID)) {
      return false;
    } else if (widget.userType == "agent" && agentLoginvisiblity.contains(widget.parentID)) {
      return false;
    }  else if (widget.userType != "agent" && widget.parentID == Config.Dashboard) {
      return false;
    } else if (otherwillshowalways.contains(widget.parentID)) {
      return false;
    } else {
      return true;
    }

  }

  @override
  Widget build(BuildContext context) {
    return shouldShowRow()
        ? Container()
        : InkWell(
            onTap: () {
              widget.onTap(widget.parenturl, widget.parentID);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 45.0, top: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
