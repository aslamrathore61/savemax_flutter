import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<String?> cropImage(File imgFile) async {
  final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
    /*  aspectRatioPresets: Platform.isAndroid ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ]
          : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
      ],*/
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Image Cropper",
            toolbarColor: Colors.red.shade800,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: "Image Cropper",
        )
      ]);

  if (croppedFile != null) {
    return croppedFile.path;
  }

  return null;
}