import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:savemax_flutter/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SharePrefFile.dart';
import '../model/native_item.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://uatapi.savemax.com/userservice/api/configs/';

  ApiProvider() {
    // Add interceptors for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Log request details only in debug mode
        assert(() {
          print('Request: ${options.method} ${options.path}');
          print('Request headers: ${options.headers}');
          print('Request data: ${options.data}');
          return true;
        }());
        return handler.next(options); // continue the request
      },
      onResponse: (response, handler) {
        // Log response details only in debug mode
        assert(() {
          print('Response: ${response.statusCode}');
          print('Response data: ${response.data}');
          return true;
        }());
        return handler.next(response); // continue the response
      },
      onError: (DioError e, handler) {
        // Log error details only in debug mode
        assert(() {
          print('Error: ${e.response?.statusCode}');
          print('Error message: ${e.message}');
          return true;
        }());
        return handler.next(e); // continue the error
      },
    ));
  }

  /***  Native Item Get From Asset ***/

  Future<NativeItem> fetchMenuDetails() async {
    String jsonString = await rootBundle.loadString('assets/jsonFile/update_menu_file.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);

    print('jsonResponse ${jsonResponse}');

    var BottomMenu = jsonResponse['BottomMenu']['Bottom'] as List?;
    var SideMenu = jsonResponse['SideMenu']['Side'] as List?;
    var ProfileMenu = jsonResponse['ProfileMenu']['Profile'] as List?;

    if (BottomMenu == null && SideMenu == null && ProfileMenu == null) {
      return NativeItem(bottom: [], side: []);
    } else {
      var bottomItems = BottomMenu!.map((e) => Bottom.fromJson(e)).toList();
      var sideItems = SideMenu!.map((e) => Side.fromJson(e)).toList();
      var profileItems = ProfileMenu!.map((e) => Profile.fromJson(e)).toList();

      return NativeItem(bottom: bottomItems, side: sideItems,profile: profileItems);
    }
  }


  // this is for ssl trust issue shold not go in production
  void configureDio() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }




  /***  Native Item Get From API ***/

/*
  Future<NativeItem> fetchMenuDetails() async {
    configureDio();

    int menuVersion = await getPrefIntegerValue(Config.REQUEST_APP_VERSION);

    try {
     Response response = await _dio.get(
        '${_baseUrl}getSaveMaxMenuItems',
        queryParameters: {'requestAppVersion': menuVersion},
      );

     // Save the responseAppVersion regardless of other conditions
     if (response.data != null && response.data['responseAppVersion'] != null) {
       var responseAppVersion = response.data['responseAppVersion'];
       await setPrefIntegerValue(Config.REQUEST_APP_VERSION, responseAppVersion);
       print('SavedRequestAppVersion: $responseAppVersion');
     }

      var jsonResponse = response.data['jsonResponse'];

      if (jsonResponse is String && jsonResponse.isEmpty) {
        // Handle empty jsonResponse
        print('Empty jsonResponse');
        return NativeItem(bottom: [], side: []);
      } else if (jsonResponse is Map && jsonResponse.containsKey('BottomMenu')) {
        // Handle jsonResponse with BottomMenu
        var bottomMenu = jsonResponse['BottomMenu']['Bottom'] as List?;
        var sideMenu = jsonResponse['SideMenu']['Side'] as List?;

        var requestAppVersion = response.data['responseAppVersion'];
        print('requestAppVersion22222 ${requestAppVersion}');
        print('BottomMenuBottomMenu ${bottomMenu}');

        if (bottomMenu == null && sideMenu == null) {
          return NativeItem(bottom: [], side: []);
        } else {
          var bottomItems = bottomMenu!.map((e) => Bottom.fromJson(e)).toList();
          var sideItems = sideMenu!.map((e) => Side.fromJson(e)).toList();

          return NativeItem(bottom: bottomItems, side: sideItems);
        }
      } else {
        // Handle unexpected jsonResponse format
        print('Unexpected jsonResponse format');
        return NativeItem(bottom: [], side: []);
      }
    } catch (e) {
      print('ExceptionError $e');
      return NativeItem(bottom: [], side: []);
    }
  }
*/

}
