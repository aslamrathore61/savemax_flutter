// Main Drawer Menu Item
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/native_item.dart';

class DrawerMenuItem extends StatefulWidget {
  final String parenturl;
  final String parentID;
  final String base64Icon;
  final String base64IconMenu;
  final List<SubItem> subList;
  final String title;

  // final bool isSelected;
  final Function onTap;

  const DrawerMenuItem({
    Key? key,
    required this.parenturl,
    required this.parentID,
    required this.base64Icon,
    required this.base64IconMenu,
    required this.subList,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<DrawerMenuItem> {
  late bool expandView = false;
  late ImageProvider _iconProvider;
  late ImageProvider _iconMenuProvider;

  @override
  void initState() {
    super.initState();
    _iconProvider = MemoryImage(base64Decode(widget.base64Icon));
    _iconMenuProvider = MemoryImage(base64Decode(widget.base64IconMenu));
  }

  @override
  Widget build(BuildContext context) {
    return widget.parentID == 'ee3579dffc5b4fb984143fa55e414323' ? Container(margin: EdgeInsets.only(top: 10, bottom: 10),width: MediaQuery.sizeOf(context).width,
    height: 0.4, decoration: BoxDecoration(border: Border(
          bottom:BorderSide(color: Colors.black, width: 0.5)
      )),) : InkWell(
      onTap: () {
        if (widget.subList.isNotEmpty) {
          setState(() {
            expandView = !expandView;
          });
        } else {
          widget.onTap(widget.parenturl, widget.parentID);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 8,
                ),
                Image(
                    image: _iconProvider,
                    width: 20,
                    height: 20,
                    color: Colors.red.shade700),
                SizedBox(width: 13),
                widget.base64IconMenu.isNotEmpty
                    ? Image(
                        image: _iconMenuProvider,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain)
                    : SizedBox(width: 0),
                SizedBox(width: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (widget.subList.isNotEmpty)
                  Icon(
                    expandView ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 20,
                  ),
              ],
            ),
          ),
          if (expandView && widget.subList.isNotEmpty)
            Container(
              margin: EdgeInsets.only(left: 50, right: 10),
              padding: EdgeInsets.only(left: 10, top: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey.shade500),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.subList.map((subItem) {
                    return ChildDrawerMenuItem(
                      base64Icon: subItem.icon!,
                      title: subItem.title!,
                      onTap: () {
                        widget.onTap(subItem.uRL, subItem.id);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// child drawer menu item class
class ChildDrawerMenuItem extends StatefulWidget {
  final String base64Icon;
  final String title;
  final Function onTap;

  const ChildDrawerMenuItem({
    Key? key,
    required this.base64Icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ChildDrawerMenuItem> createState() => _ChildDrawerMenuItemState();
}

class _ChildDrawerMenuItemState extends State<ChildDrawerMenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.base64Icon.isNotEmpty
                    ? Image.memory(
                        base64Decode(widget.base64Icon),
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain, // or other fit options
                      )
                    : SizedBox(
                        width: 0,
                      ),
                SizedBox(width: 4),
                Text(
                  widget.title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
