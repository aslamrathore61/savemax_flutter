import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io; // Import dart:io with a prefix
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

const platform = const MethodChannel('com.app.savemax_MainActivity');

const greyColor = Color(0xFFF3F4F8);
const darkGreyColor = Color(0xFFF8F9FA);

const String BaseUrl = 'https://savemax.com';

/*
void showToast(String message, Color color, Icon icon) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: color,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
*/


Future<File> createFile(Uint8List bytes) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/image.png');
  await file.writeAsBytes(bytes);
  return file;
}

Future<dynamic> ShowCapturedWidget(
    BuildContext context, Uint8List capturedImage) {
  return showDialog(
    useSafeArea: false,
    context: context,
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: Text("Captured widget screenshot"),
      ),
      body: Center(
          child: capturedImage != null
              ? Image.memory(capturedImage)
              : Container()),
    ),
  );
}


void launchAppStore(BuildContext context) async {
  final Uri androidUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.app.savemax');
  final Uri iosUrl = Uri.parse('https://apps.apple.com/us/app/yourapp/id1234567890');

  if (Theme.of(context).platform == TargetPlatform.android) {
    if (await canLaunchUrl(androidUrl)) {
      await launchUrl(androidUrl);
    } else {
      throw 'Could not launch $androidUrl';
    }
  } else if (Theme.of(context).platform == TargetPlatform.iOS) {
    if (await canLaunchUrl(iosUrl)) {
      await launchUrl(iosUrl);
    } else {
      throw 'Could not launch $iosUrl';
    }
  }
}


