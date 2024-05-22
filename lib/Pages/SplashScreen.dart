import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';
import '../bloc/native_item_bloc.dart';
import '../bloc/native_item_event.dart';
import '../bloc/native_item_state.dart';
import '../model/native_item.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NativeItemBloc nativeItemBloc = NativeItemBloc();

    BuildContext savedContext = context;

    nativeItemBloc.add(GetMenuDetailsEvents());

    nativeItemBloc.stream.listen((state) async {
      if (state is NativeItemLoaded) {
        saveDataToDatabase(state.nativeItem);
        Timer(const Duration(seconds: 3), () {
          getSavedDataFromDatabase(savedContext);
        });
      } else if (state is NativeItemError) {
        getSavedDataFromDatabase(savedContext);
        print(state.message);
      }
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icons/savemaxdoller.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

void saveDataToDatabase(NativeItem nativeItem) async {
  await Hive.openBox<NativeItem>('native_item_box');
  var box = Hive.box<NativeItem>('native_item_box');
  await box.put('native_item_key', nativeItem);
}

void getSavedDataFromDatabase(BuildContext savedContext) async {
  try {
    var box = await Hive.openBox<NativeItem>('native_item_box'); // Open the box
    NativeItem? nativeItem =
        box.get('native_item_key'); // Get the NativeItem object from the box

    if (nativeItem != null) {
      FlutterNativeSplash.remove();
      Navigator.of(savedContext)
          .pushReplacementNamed('/home', arguments: nativeItem);
    } else {
      showDialog(
          context: savedContext,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Please check your internet'),
              content: Text('Turn on mobile data or wifi'),
              actions: [
                TextButton(
                    onPressed: () {
                      SystemNavigator.pop(); // Use this on Android
                      // Or use exit(0); on iOS
                    },
                    child: Text("Close"))
              ],
            );
          });
    }
  } catch (e) {
    print('Error retrieving data: $e');
    return null;
  }
}
