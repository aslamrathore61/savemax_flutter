import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileMenuItem extends StatefulWidget {
  final String parenturl;
  final String parentID;
  final String title;

  // final bool isSelected;
  final Function onTap;

  const ProfileMenuItem({
    Key? key,
    required this.parenturl,
    required this.parentID,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ProfileMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<ProfileMenuItem> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.parenturl, widget.parentID);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 45.0),
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
