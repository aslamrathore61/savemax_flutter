import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:savemax_flutter/SharePrefFile.dart';
import 'package:savemax_flutter/model/ProfileResponse.dart';
import 'package:savemax_flutter/model/user_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Component/CircleAvatarWithDefaultImage.dart';
import '../Component/DrawerMenuItem.dart';
import '../Component/ProfileMenuItem.dart';
import '../Component/buttons/socal_button.dart';
import '../Config.dart';
import '../Utils.dart';
import '../Utils/constants.dart';
import '../main.dart';
import '../model/native_item.dart';
import 'NoInternetConnectionPage.dart';
import 'package:image_picker/image_picker.dart';


import 'package:permission_handler/permission_handler.dart';


/// Flutter code sample for [TabBar].

class TabBarPage extends StatefulWidget {
  final NativeItem nativeItem;
  late final UserInfo? userInfo;

  TabBarPage({required this.nativeItem, required this.userInfo});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late WebViewController _webViewController = WebViewController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProfileMenuVisible = false;
  bool userDetailsAvaible = false;
  bool LoadPageError = false;
  UserInfo? _userInfo;
  String mSelectedLanguageID = "";
  String mSelectedLanguageURL = "";
  File? _image;
  final picker = ImagePicker();
  late String deepLinkingURL;
  int currentTabIndex = 0;
  int delaySec = 0;


  ProfileResponse? profileResponse;

  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;
  ConnectivityResult? _initialConnectivity;

  Future<void> setupInteractedMessage() async {
    // To handle messages while your application is in the foreground, listen to the onMessage stream
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        String action = jsonEncode(message.data);
        print('action ${action}');

        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                priority: Priority.defaultPriority,
                importance: Importance.max,
                setAsGroupSummary: true,
                styleInformation: DefaultStyleInformation(true, true),
                largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                channelShowBadge: true,
                autoCancel: true,
                icon: '@mipmap/ic_launcher_round',
              ),
            ),
            payload: action);
      }
      print('A new event was published!');
    });

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    } /*else {
      handleDeepLink(null);
    }*/

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveNotificationResponse: notificationTapForeGround,
        onDidReceiveBackgroundNotificationResponse: notificationTapForeGround);
  }

  void notificationTapForeGround(NotificationResponse notificationResponse) {
    final String? payloadString = notificationResponse.payload;
    if (payloadString != null) {
      final Map<String, dynamic> payloadMap = jsonDecode(payloadString);
      final String? url = payloadMap['url'];
      handleDeepLink(url);
    }
  }

  void _handleMessage(RemoteMessage message) {
    handleDeepLink(message.data['url']);
  }

  void handleDeepLink(String? redirectLink) {

    if (redirectLink != null && redirectLink.isNotEmpty) {
      Uri uri = Uri.parse(redirectLink);
      String segmentPath = uri.path + '?' + uri.query;
      deepLinkingURL = Config.HOME_URL + segmentPath;
    } else {
      deepLinkingURL = Config.HOME_URL;
    }

    print('loadrequest 2');
    CommonLoadRequest(deepLinkingURL, _webViewController,context);



  }

  void CommonLoadRequest(String url, WebViewController webViewController, BuildContext _context) {

    javaScriptCall(webViewController,_context);
    _webViewController.loadHtmlString(html);
    //_webViewController.loadRequest(Uri.parse(url));


  }

  void CallAppIconChangerMethod(String message) async {
    await platform.invokeMethod('AppIconChange', message);
  }

  @override
  void initState() {
    super.initState();

    if (widget.userInfo != null) {
      userDetailsAvaible = true;
      _userInfo = widget.userInfo;
    }


    _connectivityStream = _connectivity.onConnectivityChanged;



    _checkInitialConnectivity();
    setupInteractedMessage();
    getSelectedLanguageID();

    _tabController = TabController(
      length: widget.nativeItem.bottom!.length,
      vsync: this,
    );


    // Load the initial URL for the first tab
    if (widget.nativeItem.bottom!.isNotEmpty &&
        widget.nativeItem.bottom![0].uRL!.isNotEmpty) {

      if (widget.nativeItem.bottom![0].uRL != null) {
        Uri uri = Uri.parse(widget.nativeItem.bottom![0].uRL!);
        String segmentPath = uri.path + '?' + uri.query;
        deepLinkingURL = Config.HOME_URL + segmentPath;
      } else {
        deepLinkingURL = Config.HOME_URL;
      }

      print('loadrequest 3');
      CommonLoadRequest(deepLinkingURL, _webViewController, context);

    }


  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onTabTapped(int index, String url, String _id) async {
    currentTabIndex = index;
    if (index == widget.nativeItem.bottom!.length - 1) {
      // Open the drawer if the last tab is selected
      _scaffoldKey.currentState?.openDrawer();


      print('checkindext ${index}');
      // Set the tab controller index to the previous tab
     _tabController.index = _tabController.previousIndex;
    } else {
      if (url.isEmpty) return;

      // Load the URL for the selected tab
      if (url.startsWith(Config.HOME_URL) ||
          url.startsWith('https://savemax.com') ||
          url.startsWith('https://uat1.savemax.com/')) {
        if (url.isNotEmpty) {
          Uri uri = Uri.parse(url);
          String segmentPath = uri.path + '?' + uri.query;
          deepLinkingURL = Config.HOME_URL + segmentPath;
        } else {
          deepLinkingURL = Config.HOME_URL;
        }

        setState(() {
          CommonLoadRequest(deepLinkingURL, _webViewController, context);
          // _webViewController.loadHtmlString(html);
        });

      } else {
        List<String> redirectwihtToken = [
          Config.preConstruction,
          Config.gameChanger,
          Config.addAssissment,
        ];

        if(widget.userInfo != null && redirectwihtToken.contains(_id)) {
          print('launchURL $url${widget.userInfo?.token}');
          _launchUrl('$url ${widget.userInfo?.token}');
        }else{
          _launchUrl(url);
        }

      }
    }
  }

  Future<void> _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _checkInitialConnectivity() async {
    _initialConnectivity = await _connectivity.checkConnectivity();
    print('_initialConnectivity ${_initialConnectivity}');
    setState(() {}); // Update the UI after checking initial connectivity
  }

  Future<void> getSelectedLanguageID() async {
    mSelectedLanguageID = await getPrefStringValue(Config.LANUAGE_ID);
    mSelectedLanguageURL = await getPrefStringValue(Config.LANUAGE_URL);
    print('mSelectedLange, ${mSelectedLanguageURL}');
  }

  /* enum AppIcon {
  black,
  gradient,
  galaxy,
}*/
  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _exitApp(context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: statusBarHeight),
        child: Scaffold(
          key: _scaffoldKey,
          /* floatingActionButton: FloatingActionButton(
            onPressed: () async {

              print('logoutGotClick');

              //   String setVlaue = "Logout";
              // _webViewController.runJavaScript('getLogout("$setVlaue")');

              String logout = "logout";
              _webViewController.runJavaScript('getLogout("$logout")');

            }
             */ /* try {
                // Check if the device supports alternate icons
                if (await FlutterDynamicIcon.supportsAlternateIcons) {
                  // Change the icon
                  await FlutterDynamicIcon.setAlternateIconName('gradient');
                }else {
                  print('notSupportAlternativeIcon');
                }
              } on PlatformException catch (_) {
                print('Failed to change app icon');
              }

              CallAppIconChangerMethod(
                  ".MainActivityB");
            },*/ /*
          ),*/
          drawer: Container(
            width: MediaQuery.of(context).size.width - 74,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.zero, // Remove the corner radius
              color: Colors.white, // Set your desired background color here
            ),
            child: Drawer(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      //isUserLogout
                      Visibility(
                        visible: !userDetailsAvaible,
                        child: Container(
                          color: Colors.grey.shade50,
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 4, bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SocalButton(
                                  color: Colors.blue.shade800,
                                  icon: Icon(Icons.input,
                                      color: Colors.white, size: 16),
                                  press: () {
                                    _scaffoldKey.currentState?.closeDrawer();
                                    _onTabTapped(0, "${Config.HOME_URL}/login",'');
                                    _tabController.index = 4;

                                  },
                                  text: "Sign-in".toUpperCase(),
                                ),
                              ),
                              const Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //    Icon(Icons.close),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Visibility(
                        visible: userDetailsAvaible,
                        child: Container(
                          color: Colors.grey.shade50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isProfileMenuVisible =
                                    !isProfileMenuVisible;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, left: 12, bottom: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatarWithDefaultImage(
                                        imageUrl: '${profileResponse?.imageUrl ?? ''}',
                                        defaultImageUrl: 'assets/images/profileimage.png',
                                        radius: 20.0,
                                      ),
                                      SizedBox(width: 10),
                                      _userInfo != null
                                          ? Text(
                                        _userInfo!.name!
                                            .split(' ')
                                            .map((String word) {
                                          return word
                                              .substring(0, 1)
                                              .toUpperCase() +
                                              word.substring(1);
                                        }).join(' '),
                                        style: TextStyle(fontSize: 14),
                                      )
                                          : Text('-'),
                                      SizedBox(width: 20),
                                      Icon(
                                        isProfileMenuVisible
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: isProfileMenuVisible,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(left: 8),
                                  itemCount: widget.nativeItem.profile?.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ProfileMenuItem(
                                      profileResponse: profileResponse,
                                      userType: _userInfo != null ? _userInfo!.userType! : '',
                                      parenturl: widget.nativeItem.profile![index].uRL!,
                                      parentID:
                                      widget.nativeItem.profile![index].id!,
                                      title: widget
                                          .nativeItem.profile![index].title!,
                                      onTap: (String url, String id) async {


                                        // use this id for logout clear local cookie
                                        if (id == Config.LOGOUT_ID) {
                                          await _webViewController.clearCache();
                                          final cookieManager =
                                          WebViewCookieManager();
                                          cookieManager.clearCookies();
                                          await _webViewController
                                              .clearLocalStorage();

                                          // clear user info
                                          var box =
                                          await Hive.openBox<UserInfo>(
                                              Config.USER_INFO_BOX);
                                          await box
                                              .delete(Config.USER_INFO_KEY);

                                          setState(() {
                                            _userInfo == null;
                                            userDetailsAvaible = false;
                                          });
                                        }

                                        _onTabTapped(0, url,id);
                                        _scaffoldKey.currentState?.closeDrawer();
                                        _tabController.index = 4;

                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemCount: widget.nativeItem.side?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return DrawerMenuItem(
                              selectedLanguageID: mSelectedLanguageID,
                              selectedLanguageURL: mSelectedLanguageURL,
                              parenturl: widget.nativeItem.side![index].uRL!,
                              parentID: widget.nativeItem.side![index].id!,
                              base64Icon: widget.nativeItem.side![index].icon!,
                              base64IconMenu:
                              widget.nativeItem.side![index].menuIcon!,
                              subList: widget.nativeItem.side![index].subList!,
                              title: widget.nativeItem.side![index].title!,
                              onTap: (String url, String id, String icon) async {


                                print('parentURL ${url} ParentID ${id}');

                                int _index = 0;
                                int foundIndex = -1;
                                widget.nativeItem.bottom?.forEach((element) {
                                  if (element.id == id) {
                                    foundIndex = _index;
                                    return;
                                  }
                                  _index++;
                                });


                                if (widget.nativeItem.side![index].id! == Config.CURRENCY_ID) {
                                  print('LanguageIDdd ${widget.nativeItem.side![index].id!}');
                                  print('LanguageID ${url}');
                                  mSelectedLanguageID = id;
                                  mSelectedLanguageURL = url;

                                  String jsCode = '{"currency": "${url}", "symbol": "${icon}"}';
                                  _webViewController.runJavaScript('changeCurrency(`$jsCode`)');
                                  await setPrefStringValue(Config.LANUAGE_ID, id);
                                  await setPrefStringValue(Config.LANUAGE_URL, url);
                                  // handle
                                } else if (foundIndex != -1) {
                                  print('parentURL  1111');

                                  _tabController.index = foundIndex;
                                  _onTabTapped(foundIndex, url, id);
                                } else {
                                  print('parentURL  2222');

                                  _onTabTapped(0, url,id);
                                  _tabController.index = 4;

                                }

                                _scaffoldKey.currentState?.closeDrawer();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _initialConnectivity == null
                    ? Center(
                  child: CircularProgressIndicator(),
                ) // Show loading indicator while checking initial connectivity
                    : StreamBuilder<ConnectivityResult>(
                  stream: _connectivityStream,
                  builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
                    // Check initial connectivity if stream has not emitted any data yet
                    final connectivityResult = snapshot.data ?? _initialConnectivity;

                    print('connectivityResult11 $connectivityResult');

                    if (snapshot.connectionState == ConnectionState.waiting && connectivityResult == null) {
                      print('connectivityResult11 13 $connectivityResult');

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }


                    if (connectivityResult != ConnectivityResult.none && LoadPageError) {
                      print('loadrequesttttt $deepLinkingURL');
                      LoadPageError = false;
                      delaySec = 3;

                        _webViewController.loadRequest(Uri.parse(deepLinkingURL));


                    }

                    if (connectivityResult == ConnectivityResult.none) {
                      LoadPageError = true;
                      return Center(
                        child: NoInternetConnectionPage(
                          tryAgain: _checkInitialConnectivity,
                        ),
                      );
                    } else {
                      // Delay before showing the WebViewWidget
                      return FutureBuilder(
                        future: Future.delayed(Duration(seconds: delaySec)), // Adjust the duration as needed
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && delaySec == 3) {
                            delaySec == 0;
                            return Center(child: CircularProgressIndicator(color: Colors.blue.shade600,));
                          } else {
                            return WebViewWidget(
                              controller: _webViewController
                             // ..loadRequest(Uri.parse(deepLinkingURL))
                                ..enableZoom(false)
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..setBackgroundColor(const Color(0x00000000))
                                ..setNavigationDelegate(
                                  NavigationDelegate(
                                    onProgress: (int progress) {
                                      print('progress $progress');
                                    },
                                    onPageStarted: (String url) {
                                      setState(() {
                                        if(url == Config.HOME_URL){
                                          _tabController.index = 0;
                                        }else if(url.contains('buy')) {
                                          _tabController.index = 1;
                                        }else if(url.contains('rent')) {
                                          _tabController.index = 2;
                                        }else if(url.contains('\$999')) {
                                          _tabController.index = 3;
                                        }

                                      });
                                      print('onPageStarted $url');
                                    },
                                    onPageFinished: (String url) {
                                      print('onPageFinished $url');
                                    },
                                    onWebResourceError: (WebResourceError error) {
                                      print('LoadPageError ${error.errorCode}');

                                      print('onWebResourceError ${error.errorType} ${error.errorCode} ${error.description}');
                                      if (error.errorCode == -2) {
                                        LoadPageError = true;

                                      } else if (error.errorCode == -8) {
                                        LoadPageError = true;
                                      }
                                    },
                                    onHttpError: (HttpResponseError error) {
                                      print('httpResponseError $error');
                                    },
                                    onNavigationRequest: (NavigationRequest request) {
                                      print('urlcheckvalue ${request.url}');
                                      return NavigationDecision.navigate;
                                    },
                                  ),
                                ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey, // Top border color for the TabBar
                  width: 0.5, // Width of the top border
                ),
              ),
            ),
            child: TabBar(
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.red, // Color of the indicator
                    width: 4.0, // Height of the indicator
                  ),
                ),
              ),
              labelPadding: EdgeInsets.symmetric(vertical: 0),
              labelStyle: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
              splashFactory: NoSplash.splashFactory,
              onTap: (index) {
                final url = widget.nativeItem.bottom![index].uRL!;
                _onTabTapped(index, url,widget.nativeItem.bottom![index].id!);
              },
              tabs: widget.nativeItem.bottom!.map((item) {
                final svgBytes = base64Decode(item.icon!);
                final svgString = utf8.decode(svgBytes);
                return Tab(
                  icon: SvgPicture.string(
                    svgString,
                    width: 24.0,
                    height: 24.0,
                    color: _tabController.index ==
                        widget.nativeItem.bottom!.indexOf(item)
                        ? Colors.red
                        : Colors.black,
                  ),
                  text: item.title,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void javaScriptCall(
      WebViewController webViewController, BuildContext context) {

    webViewController.addJavaScriptChannel('FlutterChannel',
        onMessageReceived: (message) async {
          print('FlutterChannelDetails ${message.message}');
          try {
            var data = jsonDecode(message.message);
            if (data is Map<String, dynamic>) {
              _handleJsonMessageUserInfo(data);
            } else {
              print('ReceivedNonJsonMessage: ${message.message}');
            }
          } catch (e) {
            // Handle as a plain string message
            print('ReceivedStringMessage: ${message.message}');
            _handleStringMessage(message.message, webViewController);
          }
        });
  }

  Future<void> _handleJsonMessageUserInfo(Map<String, dynamic> data) async {
    try {

      if(data['action'] == 'Share') {
        print('actionshare ${data['action']}');
        shareURL(data['text'],data['url']);
        //title
      }else if(data['flutter'] == 'profile')  {
        setState(() {
          profileResponse = ProfileResponse.fromJson(data);
        });

        print('profileRespons ${profileResponse!.toJson()}');

      }else{
        final UserInfo userInfo = UserInfo.fromJson(data);
        var box = await Hive.openBox<UserInfo>(Config.USER_INFO_BOX);
        await box.put(Config.USER_INFO_KEY, userInfo);
        setState(() {
          _userInfo = userInfo;
          userDetailsAvaible = true;
        });
      }

    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  void shareURL(String url, String text) {
    Share.share('$text\n$url');
  }

  Future<void> _handleStringMessage(
      String message, WebViewController webViewController) async {
    if (message == "getBottomToolbar") {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionNumber = packageInfo.version;
      final bundleNumber = packageInfo.buildNumber;
      print('versionNumber $versionNumber : bundleNumber $bundleNumber');
      String jsCode = '{"versionNumber": "${versionNumber}", "bundleNumber": "${bundleNumber}"}';
      webViewController.runJavaScript('getVersion(`$jsCode`)');

      //  String jsCode = '{"logoutvalue"}';
      // webViewController.runJavaScript('getLogout(`$jsCode`)');
    }else if(message == "ProvideProfileImageFormData") {
      print('ProvideProfileImageFormData');
      showOptions();
    }else if(message == "GenerateFCMToken") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString('fcmToken');
      print('fcmToken : $fcmToken');
      webViewController.runJavaScript('setToken("$fcmToken")');
    }else if(message == "GetLocation") {
      print('getcalllll');
      setLatLongToWeb(webViewController,context);

    }
  }



  Future<void> setLatLongToWeb(WebViewController webViewController, BuildContext context) async {

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

      if(permission == LocationPermission.deniedForever) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text('Please enable location permissions in your device settings to use this feature.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Open the app settings
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          ),
        );
        return;
      } else if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position? position = await Geolocator.getLastKnownPosition();
    print('CurrentLatLong - Latitude: ${position?.latitude}, Longitude: ${position?.longitude}');

    if(position?.latitude != null && position?.longitude != null) {
      String jsCode = '{"latitude": "${position?.latitude}", "longitude": "${position?.longitude}"}';
      webViewController.runJavaScript('getLatLong(`$jsCode`)');
    }
  }





  Future<void> _exitApp(BuildContext context) async {
    if (await _webViewController.canGoBack()) {
      print('WxistApp 1');
      _webViewController.goBack();
      setState(() {
        canPop = false;
      });
    } else {
      _webViewController.currentUrl().then((currentUrl) {
        print('CurrentURL: $currentUrl');
        if(currentUrl == Config.HOME_URL) {
          setState(() {
            SystemNavigator.pop();
            //canPop = true;
          });
        }
      });

    }
  }


  //Show options to get image from camera or gallery
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () async {
              // close the options modal
              Navigator.of(context).pop();

              AndroidDeviceInfo? deviceInfo;

              if (Platform.isAndroid) {
                deviceInfo = await DeviceInfoPlugin().androidInfo;
              }

              if (Platform.isAndroid &&
                  deviceInfo != null &&
                  deviceInfo.version.sdkInt <= 32) {
                var permissionStatus = await Permission.storage.request();
                if (permissionStatus.isGranted) {
                  getImageFromGallery();
                } else if (permissionStatus.isPermanentlyDenied) {
                  showPermissionSettingsDialog(context, 'Please enable storage permission in app settings to use this feature.');
                }
              } else {
                var permissionStatus = await Permission.photos.request();
                if (permissionStatus.isGranted) {
                  getImageFromGallery();
                } else if (permissionStatus.isPermanentlyDenied) {
                  showPermissionSettingsDialog(context,
                      'Please enable storage permission in app settings to use this feature.');
                }
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () async {
              // close the options modal
              Navigator.of(context).pop();
              var permissionStatus = await Permission.camera.request();

              if (permissionStatus.isGranted) {
                // get image from camera
                getImageFromCamera();
              } else if (permissionStatus.isPermanentlyDenied) {
                showPermissionSettingsDialog(context,
                    'Please enable storage permission in app settings to use this feature.');
              }
            },
          ),
        ],
      ),
    );
  }

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 25)
        .then((value) => {
      if (value != null) {cropImageCall(File(value.path))}
    });
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 25)
        .then((value) async => {
      if (value != null) {cropImageCall(File(value.path))}
    });
  }

  cropImageCall(File imgFile) async {
    String? croppedImagePath = await cropImage(imgFile);
    print("croppedImagePath $croppedImagePath");
    // Read the file at the specified path
    File file = File('$croppedImagePath');


  /*  List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    _webViewController.runJavaScript('getFileBytesData(`${'data:image/png;base64,$base64String'}`)');*/

  }

  void showPermissionSettingsDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('$msg'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }




}



// const String html = """
// <html>
// <head>
//     <title>Example Page</title>
//     <style>
//         body {
//             font-family: Arial, sans-serif;
//             background-color: #f0f0f0;
//             padding: 20px;
//         }
//         h1 {
//             color: #333;
//         }
//         p {
//             color: #666;
//         }
//     </style>
//     <script>
//         window.getFileBytesData = (filePath) => {
//             console.log('filePath:', filePath);
//             const imgElement = document.getElementById('imagePreview');
//             imgElement.src = filePath;
//         };
//
//
//
//         function sendToFlutter() {
//             if (window.FlutterChannel) {
//                 window.FlutterChannel.postMessage('ProvideProfileImageFormData');
//             } else {
//                 console.log('No native APIs found.');
//             }
//         }
//     </script>
// </head>
// <body>
//     <h1>Hello, Flutter!</h1>
//     <p>This is an example HTML file loaded into a WebView in a Flutter app.</p>
//     <button onclick="sendToFlutter()">Send Message to Flutter</button>
//     <br/><br/>
//     <img id="imagePreview" src="" alt="Image Preview" style="max-width: 100%; height: auto;"/>
// </body>
// </html>
// """;





//
// String html = """<html>
// <head>
// <title>Image Preview</title>
// </head>
// <body>
// <h1>Image Preview</h1>
// <input type="file" id="fileInput">
//  <button onclick="sendToFlutter()">Send Message to Flutter</button>
// <button onclick="previewImage()">Preview Image</button>
// <br><br>
// <div id="imagePreview"></div>
//
// <script>
//
//
//  function sendToFlutter() {
//        if(window.FlutterChannel) {
//         window.FlutterChannel.postMessage('ProvideProfileImageFormData');
// }
// };
//
// function previewImage() {
//   const fileInput = document.getElementById('fileInput');
//   const file = fileInput.files[0];
//   if (!file) {
//     alert('Please select a file.');
//     return;
//   }
//
//   const reader = new FileReader();
//   reader.onload = function (e) {
//     const base64String = e.target.result.split(',')[1];
//     getFileBytesData(base64String);
//   };
//   reader.readAsDataURL(file);
// }
//
// window.getFileBytesData = async base64String => {
// console.log('base64', base64String);
// try {
// const mimeType = base64String.match(/data:(.*);base64/)[1];
// const byteString = atob(base64String.split(',')[1]);
// const ab = new ArrayBuffer(byteString.length);
// const ia = new Uint8Array(ab);
// for (let i = 0; i < byteString.length; i++) {
// ia[i] = byteString.charCodeAt(i);
// }
// const blob = new Blob([ab], { type: mimeType });
// const formData = new FormData();
// formData.append('file', blob, 'fileName');
//
// // Create object URL from Blob
// const imageUrl = URL.createObjectURL(blob);
// console.log('imageUrl', imageUrl);
//
// // Create image element and set its source to the object URL
// const image = new Image();
// image.src = imageUrl;
// const imagePreviewDiv = document.getElementById('imagePreview');
// imagePreviewDiv.innerHTML = '';
// imagePreviewDiv.appendChild(image);
//
// // Log form data entries
// for (const entry of formData.entries()) {
// console.log('formdataEntry', entry);
// }
// // await uploadProfileImage(formData);
// } catch (error) {
// console.error('Error in loop:', error);
// }
// };
// </script>
// </body>
// </html>
//     """;
//



String html = """
<html>
<head>
    <title>Example Page</title>
    <style>
        body {
          font-family: Arial, sans-serif;
          background-color: #f0f0f0;
          padding: 20px;
        }
        h1 {
          color: #333;
        }
        p {
          color: #666;
        }
    </style>
    <script>



    window.getLatLong = (latlng) => {
const { latitude, longitude } = JSON.parse(latlng);
console.log('flutterLocationLat:', latitude);
console.log('flutterLocationLng:', longitude);
};


  // window.getFileBytesData = async base64String => {
  //   console.log('base64', base64String);
  //   try {
  //     const mimeType = base64String.match(/data:(.*);base64/)[1];
  //     const byteString = atob(base64String.split(',')[1]);
  //     const ab = new ArrayBuffer(byteString.length);
  //     const ia = new Uint8Array(ab);
  //     for (let i = 0; i < byteString.length; i++) {
  //       ia[i] = byteString.charCodeAt(i);
  //     }
  //     const blob = new Blob([ab], { type: mimeType });
  //     const formData = new FormData();
  //     formData.append('file', blob, 'fileName');
  //
  //       console.log('formdataEntry', formData);
  //
  //    await uploadProfileImage(formData);
  //   } catch (error) {
  //     console.error('Error in loop:', error);
  //   }
  // };

        function sendToFlutter() {
       if(window.FlutterChannel) {
               console.log('GetLocation')

          window.FlutterChannel.postMessage('GetLocation');
     //   window.FlutterChannel.postMessage('ProvideProfileImageFormData');
} else {
        // No Android or iOS, Flutter interface found
        console.log('No native APIs found.')
    }
        }
    </script>
</head>
<body>
<h1>Hello, Flutter!</h1>
<p>This is an example HTML file loaded into a WebView in a Flutter app.</p>
<button onclick="sendToFlutter()">Send Message to Flutter</button>
</body>
</html>
    """;
