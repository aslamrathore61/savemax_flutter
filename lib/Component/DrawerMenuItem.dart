// Main Drawer Menu Item
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:savemax_flutter/Config.dart';

import '../SharePrefFile.dart';
import '../model/native_item.dart';

class DrawerMenuItem extends StatefulWidget {
  final String selectedLanguageID;
  final String selectedLanguageURL;
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
    required this.selectedLanguageID,
    required this.selectedLanguageURL,
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
  late ImageProvider _iconMenuProvider;
  late String svgString;

  @override
  void initState() {
    super.initState();

      _iconMenuProvider = MemoryImage(base64Decode(widget.base64IconMenu));

    print('mSelectedLange22, ${widget.selectedLanguageID}');

    if(widget.base64Icon.isNotEmpty) {
      final svgBytes = base64Decode(widget.base64Icon);
      svgString = utf8.decode(svgBytes);
    }
  }


  @override
  Widget build(BuildContext context) {
    // this validation check for draw border line between view
    return widget.parentID == 'ee3579dffc5b4fb984143fa55e414323' ? Container(margin: EdgeInsets.only(top: 10, bottom: 10),width: MediaQuery.sizeOf(context).width,
    height: 0.4, decoration: BoxDecoration(border: Border(
          bottom:BorderSide(color: Colors.black, width: 0.2)
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
            height: 41,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 8,
                ),

                  SvgPicture.string(
                    svgString,
                    color: Colors.red.shade600,
                    width: 18.0,
                    height: 18.0,

                  ),

                SizedBox(width: 13),
                widget.base64IconMenu.isNotEmpty
                    ? Image(
                        image: _iconMenuProvider,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain)
                    : SizedBox(width: 0),
                SizedBox(width: 4),

                widget.parentID == Config.CURRENCY_ID ?
                Text(
                 widget.selectedLanguageURL == '' ? "CAD" : widget.selectedLanguageURL,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.normal,
                  ),
                ) : Text(
                 widget.title,
                  style: TextStyle(
                    fontSize: 13.0,
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
              padding: EdgeInsets.only(left: 10, top: 2),
              width: MediaQuery.of(context).size.width,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10.0),
              //   border: Border.all(color: Colors.grey.shade500),
              // ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.subList.map((subItem) {

                    return ChildDrawerMenuItem(
                      base64Icon: subItem.icon!,
                      title: subItem.title!,
                      id: subItem.id!,
                      selectedLangID: widget.selectedLanguageID,
                      onTap: () {
                        print('submenuclick ${subItem.uRL} "${subItem.id}');
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
  final String id;
  final String selectedLangID;
  final Function onTap;

  const ChildDrawerMenuItem({
    Key? key,
    required this.base64Icon,
    required this.title,
    required this.id,
    required this.selectedLangID,
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
        padding: const EdgeInsets.only(bottom: 8.0),
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
                    fontSize: 13.0,
                    color: widget.id == widget.selectedLangID ? Colors.red : Colors.black ,
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
