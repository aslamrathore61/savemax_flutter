import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

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

/*  Future<NativeItem> fetchMenuDetails() async {
    String jsonString = await rootBundle.loadString('assets/jsonFile/update_menu_file.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);

    var BottomMenu = jsonResponse['BottomMenu']['Bottom'] as List?;
    var SideMenu = jsonResponse['SideMenu']['Side'] as List?;

    if (BottomMenu == null && SideMenu == null) {
      return NativeItem(bottom: [], side: []);
    } else {
      var bottomItems = BottomMenu!.map((e) => Bottom.fromJson(e)).toList();
      var sideItems = SideMenu!.map((e) => Side.fromJson(e)).toList();

      return NativeItem(bottom: bottomItems, side: sideItems);
    }
  }*/


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

  Future<NativeItem> fetchMenuDetails() async {
    //configureDio();



    try{
      Response response = await _dio.get('${_baseUrl}getSaveMaxMenuItems');
      var BottomMenu = response.data['BottomMenu']['Bottom'] as List?;
      var SideMenu = response.data['SideMenu']['Side'] as List?;


      if (BottomMenu == null && SideMenu == null) {
        return NativeItem(bottom: [], side: []);
      } else {
        var bottomItems = BottomMenu!.map((e) => Bottom.fromJson(e)).toList();
        var sideItems = SideMenu!.map((e) => Side.fromJson(e)).toList();

        return NativeItem(bottom: bottomItems, side: sideItems);
      }
    }catch(e){
      print('ExceptionError ${e}');
      return NativeItem(bottom: [], side: []);

    }

  }
}
