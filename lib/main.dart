import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart';
import 'package:savemax_flutter/model/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Component/UpdateMaintainance/ForceUpdateScreen.dart';
import 'Component/UpdateMaintainance/MaintenanceScreen.dart';
import 'Network/ApiProvider.dart';
import 'Pages/SplashScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'Pages/TabBarPage.dart';
import 'model/native_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
AndroidNotificationChannel? channel;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;


  Future<void> getLocationInitialTime() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }



  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );



  Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NativeItemAdapter());
    Hive.registerAdapter(BottomAdapter());
    Hive.registerAdapter(SideAdapter());
    Hive.registerAdapter(SubItemAdapter());
    Hive.registerAdapter(ProfileAdapter());
    Hive.registerAdapter(UserInfoAdapter());
  }

  await getLocationInitialTime();

  bool result = await InternetConnection().hasInternetAccess;

  if(result) {
    final fcmToken = await messaging.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', '$fcmToken');
  }

  channel = const AndroidNotificationChannel(
      'flutter_notification', // id
      'flutter_notification_title', // title
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      showBadge: true,
      playSound: true);


  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await messaging
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await initializeHive();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.light, // Always use light theme
    theme: ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Poppins', // Specify your custom font
      // Customize your light theme here
    ),
    home: RepositoryProvider(
      create: (context) => ApiProvider(),
      child: SplashScreen(),
    ),
    routes: {
      '/home': (context) {
        final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final UserInfo? userInfo = args['userInfo'];
        final NativeItem nativeItem = args['nativeItem'];
        return TabBarPage(nativeItem: nativeItem, userInfo: userInfo,);
      },
      '/forceUpdatePage': (context) {
        return ForceUpdateScreen();
      },
      '/maintenancePage': (context) {
        return MaintenanceScreen();
      },
    },

  ));
}
