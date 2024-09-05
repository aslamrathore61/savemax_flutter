import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:savemax_flutter/SharePrefFile.dart';
import 'package:savemax_flutter/model/ProfileResponse.dart';
import 'package:savemax_flutter/model/user_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
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
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

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
class _TabBarPageState extends State<TabBarPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // GlobalKey<_TabBarPageState> _key = GlobalKey();

  late final TabController _tabController;
  late final WebViewController _webViewController;
  bool _isGestureDisabled = false; // Track whether gestures are disabled

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProfileMenuVisible = false;
  bool userDetailsAvaible = false;
  UserInfo? _userInfo;
  String mSelectedLanguageID = "";
  String mSelectedLanguageURL = "";
  String _initialLink = "";
  File? _image;
  final picker = ImagePicker();
  late String deepLinkingURL;
  int currentTabIndex = 0;
  bool tabGetChangesAfterInternetGon = false;
  bool launchFirstTime = true;
  bool IsInternetConnected = true;

  ProfileResponse? profileResponse;
  bool profileUpdated = false;
  bool isLoading = false;
  bool isAppInBackground = false;
  bool isKeyboardOpen = false;

  Future<void> setupInteractedMessage() async {
    // To handle messages while your application is in the foreground, listen to the onMessage stream
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        String action = jsonEncode(message.data);
        print('action $action');

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
    }
    /*else {
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
    CommonLoadRequest(deepLinkingURL, _webViewController, context, "1");
  }

  void CommonLoadRequest(String url, WebViewController webViewController,
      BuildContext _context, String debugValue) {
    print('debugValue : $debugValue');

    if (IsInternetConnected) {
      javaScriptCall(webViewController, _context);
      // _webViewController.loadHtmlString(html);
      _webViewController.loadRequest(Uri.parse(url));
    }
  }

  Future<void> initUniLinks() async {
    try {
      _initialLink = (await getInitialLink())!;
      if (_initialLink != null && IsInternetConnected) {
        // Handle the initial link here
        deepLinkingURL = _initialLink;
        //  handleDeepLink(_initialLink);
      }
    } on PlatformException {
      // _initialLink = null;
    }
  }

  void _internetConnectionStatus() {
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (!isAppInBackground) {
        switch (status) {
          case InternetStatus.connected:
            setState(() async {
              print("internetConnected connected");
              if (tabGetChangesAfterInternetGon || launchFirstTime) {
                launchFirstTime = false;
                IsInternetConnected = true;
                CommonLoadRequest(
                    deepLinkingURL, _webViewController, context, "2");
              }
            });

            setState(() {
              IsInternetConnected = true;
            });
            /*  Future.delayed(Duration(microseconds: 1000), () {
              setState(() {
                IsInternetConnected = true;
              });
            });*/
            break;
          case InternetStatus.disconnected:
            print("internetConnected Notconnected");
            setState(() {
              IsInternetConnected = false;
            });
            break;
        }
      }
    });
  }

  void CallAppIconChangerMethod(String message) async {
    await platform.invokeMethod('AppIconChange', message);
  }

  @override
  void deactivate() {
    //   print('deactivate');
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //  print('didChangeDependencies');

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _webViewController.currentUrl().then((currentUrl) {
        if (currentUrl != null && currentUrl.contains('buy')) {
          extractCityName(currentUrl);
          _tabController.index = 1;
        }
      });
    }
  }

  void _rebuildWidget() {
    setState(() {
      // _key = GlobalKey(); // Change the key to force rebuild
      _scaffoldKey =
          GlobalKey<ScaffoldState>(); // Change the key to force rebuild
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    setState(() {
      isAppInBackground = (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive);
      print('inAppInBackground');
    });

    switch (state) {
      case AppLifecycleState.inactive:
        // App is inactive
        print('AppLifecycleState $state');
        break;
      case AppLifecycleState.hidden:
        print('AppLifecycleState $state');
        break;
      case AppLifecycleState.paused:
        // App is
        print('AppLifecycleState $state');
        break;
      case AppLifecycleState.resumed:
        print('AppLifecycleState $state');
        if (!isKeyboardOpen) {
          _rebuildWidget();
        }

        break;
      case AppLifecycleState.detached:
        print('AppLifecycleState $state');

        // App is detached
        break;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xe8f3f4f8), // Change this to the desired color
      statusBarIconBrightness: Brightness.dark, // For dark status bar icons
    ));

    _internetConnectionStatus();

    if (widget.userInfo != null) {
      userDetailsAvaible = true;
      _userInfo = widget.userInfo;
    }

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        // allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);

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

      // CommonLoadRequest(deepLinkingURL, _webViewController, context,"3");
    }
  }

  Future<void> _onTabTapped(int index, String url, String _id) async {
    print('idtest $_id');
    String updateurl = url;

    if (url.contains('buy') || url.contains('rent')) {
      final cityName = await getPrefStringValue(Config.UpdateCityName);
      print('urlCityName $cityName');

      url = updateurl.replaceFirst('toronto', cityName);
    }

    currentTabIndex = index;
    if (index == widget.nativeItem.bottom!.length - 1) {
      // Open the drawer if the last tab is selected
      _scaffoldKey.currentState?.openDrawer();

      print('checkindext $index');
      // Set the tab controller index to the previous tab
      _tabController.index = _tabController.previousIndex;
    } else {
      if (url.isEmpty) return;

      if (!IsInternetConnected) {
        tabGetChangesAfterInternetGon = true;
      }

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

        bool result = await InternetConnection().hasInternetAccess;
        setState(() {
          IsInternetConnected = result;
        });

        setState(() {
          if (IsInternetConnected) {
            print('isInternetConnected:: $IsInternetConnected');
            CommonLoadRequest(deepLinkingURL, _webViewController, context, "4");
          }
        });
      } else {
        List<String> redirectwihtToken = [
          Config.preConstruction,
          Config.gameChanger,
          Config.addAssissment,
        ];

        if (redirectwihtToken.contains(_id)) {
          print('userInfoDetails ${_userInfo?.toJson()}');
          print('launchURL $url${widget.userInfo?.token}');
        //  final token = widget.userInfo?.token ?? _userInfo?.token;
          final token = _userInfo?.token ??  widget.userInfo?.token;
          _launchUrl(token != null ? '$url $token' : url);
        } else {
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
    bool result = await InternetConnection().hasInternetAccess;

    if (result) {
      setState(() async {
        IsInternetConnected = true;
        CommonLoadRequest(deepLinkingURL, _webViewController, context, "2");
      });
    } else {
      setState(() {
        IsInternetConnected = false;
      });
    }
  }

  Future<void> getSelectedLanguageID() async {
    mSelectedLanguageID = await getPrefStringValue(Config.LANUAGE_ID);
    mSelectedLanguageURL = await getPrefStringValue(Config.LANUAGE_URL);
  }

  bool canPop = false;
  late double _statusBarHeight;

  @override
  Widget build(BuildContext context) {
    _statusBarHeight = MediaQuery.of(context).padding.top;
    return PopScope(
      // key: _key,
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _exitApp(context);
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.red,
            //    margin: EdgeInsets.only(top: _statusBarHeight),
            child: Scaffold(
              key: _scaffoldKey,
              drawer: Container(
                width: MediaQuery.of(context).size.width - 74,
                margin: EdgeInsets.only(top: _statusBarHeight),
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
                                        _scaffoldKey.currentState
                                            ?.closeDrawer();
                                        _onTabTapped(
                                            0, "${Config.HOME_URL}/login", '');
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircleAvatarWithDefaultImage(
                                            imageUrl:
                                                '${profileResponse?.imageUrl ?? ''}',
                                            defaultImageUrl:
                                                'assets/images/profileimage.png',
                                            radius: 20.0,
                                          ),
                                          SizedBox(width: 10),

                                          Text(
                                            (profileResponse?.name?.trim().isEmpty ?? true ? 'Hi' : profileResponse!.name!)
                                                .split(' ')
                                                .take(2)
                                                .map((String word) {
                                              return word.isNotEmpty
                                                  ? word.substring(0, 1).toUpperCase() + (word.length > 1 ? word.substring(1) : '')
                                                  : ''; // Handle empty strings
                                            }).join(' ').trim(),
                                            style: TextStyle(fontSize: 14),
                                          ),

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
                                      itemCount:
                                          widget.nativeItem.profile?.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ProfileMenuItem(
                                          profileResponse: profileResponse,
                                          userType: _userInfo != null
                                              ? _userInfo!.userType!
                                              : '',
                                          parenturl: widget
                                              .nativeItem.profile![index].uRL!,
                                          parentID: widget
                                              .nativeItem.profile![index].id!,
                                          title: widget.nativeItem
                                              .profile![index].title!,
                                          onTap: (String url, String id) async {
                                            // use this id for logout clear local cookie
                                            if (id == Config.LOGOUT_ID) {
                                              await _webViewController
                                                  .clearCache();
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

                                            _onTabTapped(0, url, id);
                                            _scaffoldKey.currentState
                                                ?.closeDrawer();
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
                                  parenturl:
                                      widget.nativeItem.side![index].uRL!,
                                  parentID: widget.nativeItem.side![index].id!,
                                  base64Icon:
                                      widget.nativeItem.side![index].icon!,
                                  base64IconMenu:
                                      widget.nativeItem.side![index].menuIcon!,
                                  subList:
                                      widget.nativeItem.side![index].subList!,
                                  title: widget.nativeItem.side![index].title!,
                                  onTap: (String url, String id,
                                      String icon) async {
                                    print('parentURL $url ParentID $id');

                                    int _index = 0;
                                    int foundIndex = -1;
                                    widget.nativeItem.bottom
                                        ?.forEach((element) {
                                      if (element.id == id) {
                                        foundIndex = _index;
                                        return;
                                      }
                                      _index++;
                                    });

                                    if (widget.nativeItem.side![index].id! ==
                                        Config.CURRENCY_ID) {
                                      print(
                                          'LanguageIDdd ${widget.nativeItem.side![index].id!}');
                                      print('LanguageID $url');
                                      mSelectedLanguageID = id;
                                      mSelectedLanguageURL = url;

                                      String jsCode =
                                          '{"currency": "$url", "symbol": "$icon"}';
                                      _webViewController.runJavaScript(
                                          'changeCurrency(`$jsCode`)');
                                      await setPrefStringValue(
                                          Config.LANUAGE_ID, id);
                                      await setPrefStringValue(
                                          Config.LANUAGE_URL, url);
                                      // handle
                                    } else if (foundIndex != -1) {

                                      _tabController.index = foundIndex;
                                      _onTabTapped(foundIndex, url, id);
                                    } else {

                                      if (id == Config.inAppLocaationID) {
                                        if (Platform.isAndroid) {
                                          _launchUrl(url);
                                        } else {
                                          _launchUrl(
                                              'https://apps.apple.com/us/app/save-max-real-estate-india/id6451472373');
                                        }
                                      } else {
                                        _onTabTapped(0, url, id);
                                        _tabController.index = 4;
                                      }
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
              body: IsInternetConnected == false
                  ? Center(
                      child: NoInternetConnectionPage(
                        tryAgain: _checkInitialConnectivity,
                      ),
                    )
                  : Container(
                      color: Color(0xe8f3f4f8),
                      padding: EdgeInsets.only(top: _statusBarHeight),
                      // margin: EdgeInsets.only(top: _statusBarHeight),
                      child: WebViewWidget(
                        controller: _webViewController
                          //  ..loadRequest(Uri.parse(deepLinkingURL))
                          ..enableZoom(false)
                          // ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
                          //   print("ddd [${message.level.name}] ${message.message}");
                          // })
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..setBackgroundColor(const Color(0x00000000))
                          ..setNavigationDelegate(
                            NavigationDelegate(
                              onProgress: (int progress) {
                                print('progress $progress');
                              },
                              onPageStarted: (String url) {
                                print('onPageStarted $url');
                                setState(() {
                                  if (url == Config.HOME_URL) {
                                    _tabController.index = 0;
                                  } else if (url.contains('buy')) {
                                    _tabController.index = 1;
                                  } else if (url.contains('rent')) {
                                    _tabController.index = 2;
                                  } else if (url.contains('\$999')) {
                                    _tabController.index = 3;
                                  }
                                });
                              },
                              onPageFinished: (String url) {
                                print('onPageFinished $url');

                                String value = "";
                                setState(() {
                                  if (url.contains('buy')) {
                                    extractCityName(url);
                                    _tabController.index = 1;
                                  } else if (url.contains('rent')) {
                                    extractCityName(url);
                                  }
                                });

                                print('ValueExtract : $value');
                              },
                              onWebResourceError: (WebResourceError error) {
                                print(
                                    "errorssssss: ${error.errorCode} ${error.description}");

                                if (error.errorCode == -2) {
                                  setState(() {
                                    IsInternetConnected = false;
                                  });
                                }

                                /* print('onWebResourceError ${error.errorType} ${error.errorCode} ${error.description}');

                                            if (error.errorCode == -2) {
                                            } else if (error.errorCode == -8) {
                                            }else if(error.errorCode == -1001) {
                                            }else if(error.errorCode == -999) {
                                            }
                                          */
                              },
                              onHttpError: (HttpResponseError error) {
                                print('httpResponseError $error');
                              },
                              onNavigationRequest: (NavigationRequest request) {

                                final url = request.url;
                                print("launchUrlll $url");
                                if(url.contains("https://savemax.com/blogs/")) {
                                  _launchUrl(url);
                                  return NavigationDecision.prevent;
                                }

                                if(url.contains(Config.HOME_URL) || url.contains("https://www.youtube.com/embed") || url.contains("https://form.jotform.com")) {
                                  return NavigationDecision.navigate;
                                }else {
                                  _launchUrl(url);
                                  return NavigationDecision.prevent;
                                }


                              /*  print('onNavigationRequest ${request.url}');
                                // Handle mailto links
                                if (url.startsWith('mailto:') ||
                                    url.contains('UCsj05jLd-DMLhk_gqpZDGeA')) {
                                  _launchUrl(url);
                                  return NavigationDecision.prevent;
                                }
                                if (url.contains("https://api.whatsapp.com")) {
                                  _launchUrl(url);
                                  return NavigationDecision.prevent;
                                } else if (url.contains("tel:")) {
                                  _launchUrl(url);
                                  return NavigationDecision.prevent;
                                }

                                // Handle social media and store links
                                final socialMediaPrefixes = [
                                  'https://play.google.com',
                                  'https://apps.apple.com',
                                  'https://www.facebook.com',
                                  'https://twitter.com',
                                  'https://www.instagram.com',
                                  'https://www.linkedin.com',
                                  'https://ca.linkedin.com',
                                  'https://www.tiktok.com',
                                  'https://savemax.com/blogs/',
                                  'https://risewithraman.com/',
                                  'https://savemax.bamboohr.com/careers',
                                  'https://tour',
                                ];

                                for (var prefix in socialMediaPrefixes) {
                                  if (url.startsWith(prefix)) {
                                    _launchUrl(url);
                                    return NavigationDecision.prevent;
                                  }
                                }

                                return NavigationDecision.navigate;*/
                              },
                            ),
                          ),
                      ),
                    ),
              bottomNavigationBar: AbsorbPointer(
                absorbing: _isGestureDisabled, // Disable gestures when true
                child: Container(
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

                    if (!_isGestureDisabled) {
                      final url = widget.nativeItem.bottom![index].uRL!;
                      _onTabTapped(index, url, widget.nativeItem.bottom![index].id!);

                      setState(() {
                        _isGestureDisabled = true; // Disable gestures
                      });

                      Timer(Duration(seconds: 1), () {
                        setState(() {
                          _isGestureDisabled = false; // Re-enable gestures after 5 seconds
                        });
                      });

                    }

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
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade900,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> extractCityName(String url) async {
    print('extractCityName : $url');
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // Assuming the city name is always in the second segment
    String cityName = segments[1].replaceAll('-real-estate', '');
    await setPrefStringValue(Config.UpdateCityName, cityName);
  }

  void javaScriptCall(
      WebViewController webViewController, BuildContext context) {
    webViewController.removeJavaScriptChannel('FlutterChannel');
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
      if (data['action'] == 'Share') {
        print('actionshare ${data['action']}');
        shareURL(data['text'], data['url']);
        //title
      } else if (data['flutter'] == 'profile') {
       /* if (!profileUpdated) {
          profileUpdated = true;
          setState(() {
            print('thisOneGetCall ${profileResponse?.name}');
            profileResponse = ProfileResponse.fromJson(data);
          });
        }*/

        setState(() {
          print('thisOneGetCall ${profileResponse?.name}');
          profileResponse = ProfileResponse.fromJson(data);
        });

        print('profileRespons ${profileResponse!.toJson()}');
      } else {
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

  Future<void> shareURL(String url, String text) async {
    ShareResult shareResult = await Share.share('$text\n$url');
    /*  if(shareResult.status == ShareResultStatus.success) {
   }
*/
  }

  Future<void> _handleStringMessage(
      String message, WebViewController webViewController) async {
    if (message == "getBottomToolbar") {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionNumber = packageInfo.version;
      final bundleNumber = packageInfo.buildNumber;
      print('versionNumber $versionNumber : bundleNumber $bundleNumber');
      String jsCode =
          '{"versionNumber": "$versionNumber", "bundleNumber": "$bundleNumber"}';
      webViewController.runJavaScript('getVersion(`$jsCode`)');

      //  String jsCode = '{"logoutvalue"}';
      // webViewController.runJavaScript('getLogout(`$jsCode`)');
    } else if (message == "ProvideProfileImageFormData") {
      print('ProvideProfileImageFormData');
      showOptions("profileImage");
    } else if (message == "ProvideListingImageFormData") {
      print('ProvideListingImageFormData');
      showOptions("ListingImage");
    } else if (message == "GenerateFCMToken") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString('fcmToken');
      print('fcmToken : $fcmToken');
      webViewController.runJavaScript('setToken("$fcmToken")');
    } else if (message == "GetLocation") {
      print('getcalllll');
      setLatLongToWeb(webViewController, context);
    }
  }

  Future<void> setLatLongToWeb(
      WebViewController webViewController, BuildContext context) async {
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
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
              'Please enable location permissions in your device settings to use this feature.'),
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
      print('check 6');
      return;
    }
    Position? position = await Geolocator.getLastKnownPosition();

    print(
        'CurrentLatLong - Latitude: ${position?.latitude}, Longitude: ${position?.longitude}');

    if (position?.latitude != null && position?.longitude != null) {
      String jsCode =
          '{"latitude": "${position?.latitude}", "longitude": "${position?.longitude}"}';
      webViewController.runJavaScript('getLatLong(`$jsCode`)');
    }
  }

  Future<void> _exitApp(BuildContext context) async {
    String CurrentUrl = "";
    _webViewController.currentUrl().then((currentUrl) {
      CurrentUrl = currentUrl!;
    });

    if (await _webViewController.canGoBack()) {
      print('WxistApp 1');
      _webViewController.goBack();
      setState(() {
        canPop = false;
      });
    } else if (_initialLink == CurrentUrl) {
      SystemNavigator.pop();
    } else {
      _webViewController.currentUrl().then((currentUrl) {
        print('CurrentURL: $currentUrl');
        if (currentUrl == Config.HOME_URL) {
          setState(() {
            SystemNavigator.pop();
            //canPop = true;
          });
        }
      });
    }
  }

  //Show options to get image from camera or gallery
  Future showOptions(String imageType) async {
    AndroidDeviceInfo? deviceInfo;

    if (Platform.isAndroid) {
      deviceInfo = await DeviceInfoPlugin().androidInfo;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () async {
                  // close the options modal
                  Navigator.of(context).pop();

                  if (Platform.isAndroid && deviceInfo != null && deviceInfo.version.sdkInt <= 32) {
                    var permissionStatus = await Permission.storage.request();
                    if (permissionStatus.isGranted) {
                      getImageFromGallery(imageType);
                    } else if (permissionStatus.isPermanentlyDenied) {
                      showPermissionSettingsDialog(context,
                          'Please enable storage permission in app settings to use this feature.');
                    }
                  } else {

                    getImageFromGallery(imageType);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () async {
                  // close the options modal
                  Navigator.of(context).pop();



                  if (Platform.isAndroid && deviceInfo != null && deviceInfo.version.sdkInt <= 32) {
                    var permissionStatus = await Permission.camera.request();

                    if (permissionStatus.isGranted) {
                      // get image from camera
                      getImageFromCamera(imageType);
                    } else if (permissionStatus.isPermanentlyDenied) {
                      showPermissionSettingsDialog(context,
                          'Please enable storage permission in app settings to use this feature.');
                    }
                  } else {
                    final permissionStatus = await Permission.camera.status;
                    if (permissionStatus.isPermanentlyDenied) {
                      showPermissionSettingsDialog(context,
                          'Please enable storage permission in app settings to use this feature.');
                    } else {
                      getImageFromCamera(imageType);
                    }
                  }
                },
              )
            ],
          ),
        );
      },
    );

    // showCupertinoModalPopup(
    //   context: context,
    //   builder: (context) => Center(
    //     child: CupertinoActionSheet(
    //       actions: [
    //         Container(
    //           color: Color(0xe81a61a8),
    //           child: CupertinoActionSheetAction(
    //             child: Text('Photo Gallery',style: TextStyle(color: Colors.white),),
    //             onPressed: () async {
    //               // close the options modal
    //               Navigator.of(context).pop();
    //
    //               if (Platform.isAndroid && deviceInfo != null && deviceInfo.version.sdkInt <= 32) {
    //                 var permissionStatus = await Permission.storage.request();
    //                 if (permissionStatus.isGranted) {
    //                   getImageFromGallery(imageType);
    //                 } else if (permissionStatus.isPermanentlyDenied) {
    //                   showPermissionSettingsDialog(context,
    //                       'Please enable storage permission in app settings to use this feature.');
    //                 }
    //               } else {
    //
    //                 getImageFromGallery(imageType);
    //               }
    //             },
    //           ),
    //         ),
    //         Container(
    //           color:Color(0xe81a61a8),
    //           child: CupertinoActionSheetAction(
    //             child: Text('Camera',style: TextStyle(color: Colors.white),),
    //             onPressed: () async {
    //               // close the options modal
    //               Navigator.of(context).pop();
    //
    //
    //
    //               if (Platform.isAndroid && deviceInfo != null && deviceInfo.version.sdkInt <= 32) {
    //                 var permissionStatus = await Permission.camera.request();
    //
    //                 if (permissionStatus.isGranted) {
    //                   // get image from camera
    //                   getImageFromCamera(imageType);
    //                 } else if (permissionStatus.isPermanentlyDenied) {
    //                   showPermissionSettingsDialog(context,
    //                       'Please enable storage permission in app settings to use this feature.');
    //                 }
    //               } else {
    //                 final permissionStatus = await Permission.camera.status;
    //                 if (permissionStatus.isPermanentlyDenied) {
    //                   showPermissionSettingsDialog(context,
    //                       'Please enable storage permission in app settings to use this feature.');
    //                 } else {
    //                   getImageFromCamera(imageType);
    //                 }
    //               }
    //
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );





  }

  //Image Picker function to get image from gallery

  List<XFile> images = [];
  List<XFile> croppedImageXFile = [];

  Future getImageFromGallery(String imageType) async {
    croppedImageXFile.clear();
    if (imageType == "profileImage") {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 25);

        if (pickedFile != null) {
          cropImageCall(File(pickedFile.path), imageType);
        } else {
          print('No image selected.');
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          showPermissionSettingsDialog(context,
              'Please enable photos permission in app settings to use this feature.');
        } else {
          print('PlatformException: ${e.message}');
        }
      } catch (e) {
        print('An unexpected error occurred: $e');
      }
    } else {
      try {
        final List<XFile>? selectedImages = await picker.pickMultiImage(imageQuality: 25);
        if (selectedImages != null) {
          List<XFile> processedImages = [];

          // Process images: compress PNGs
          for (XFile image in selectedImages) {
            if (image.path.endsWith('.png')) {
              XFile compressedImage = await compressPngImage(File(image.path));
              processedImages.add(XFile(compressedImage.path));
            } else {
              // JPEG images are already compressed by imageQuality, add them as is
              processedImages.add(image);
            }
          }

          setState(() {
            images = processedImages;
            isLoading = true;
          });

          await uploadImages(images, "imageType"); // Use appropriate imageType

          setState(() {
            isLoading = false;
          });
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          showPermissionSettingsDialog(context,
              'Please enable photos permission in app settings to use this feature.');
        } else {
          print('PlatformException: ${e.message}');
        }
      } catch (e) {
        print('An unexpected error occurred: $e');
      }
    }
  }


  Future<XFile> compressPngImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${file.path}_compressed.png",
      quality: 50, // PNG compression; works differently from JPEG
      format: CompressFormat.png,
    );

    return result!;
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera(String imageType) async {
    croppedImageXFile.clear();
    try {
      await picker
          .pickImage(source: ImageSource.camera, imageQuality: 25)
          .then((value) async => {
                if (value != null) {cropImageCall(File(value.path), imageType)}
              });
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        showPermissionSettingsDialog(context,
            'Please enable camera permission in app settings to use this feature.');
      } else {
        print('PlatformException: ${e.message}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }


  cropImageCall(File imgFile, String imageType) async {
    String? croppedImagePath = await cropImage(imgFile);
    print("croppedImagePath $croppedImagePath");
    croppedImageXFile.add(XFile(croppedImagePath!));
    setState(() {
      isLoading = true;
    });
    // Read the file at the specified path
    uploadImages(croppedImageXFile, imageType);
  }

  Future<void> uploadImages(List<XFile> imageFiles, String imageType) async {
    final dio = Dio();
    const url = 'https://api.savemax.com/imageservice/uploadMultipleFiles';

    List<MultipartFile> files = [];
    for (XFile image in imageFiles) {
      String formattedDate =
          DateFormat('yyyy-MM-dd HHmmss').format(DateTime.now());
      String name = 'properties_$formattedDate.png';
      files.add(await MultipartFile.fromFile(image.path, filename: name));
    }

    FormData formData = FormData.fromMap({
      'files': files,
    });

    try {
      final response = await dio.post(url, data: formData);
      final responseData = jsonEncode(response.data);

      if (response.statusCode == 200) {
        profileUpdated = false;
        setState(() {
          isLoading = false;
        });

        if (imageType == "profileImage") {
          print('responseDataprofileImage : $responseData');
          _webViewController.runJavaScript('getFileBytesData(`$responseData`)');
        } else {
          _webViewController
              .runJavaScript('getFileBytesDataListing(`$responseData`)');
        }
      } else {
        print('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
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



//     window.getLatLong = (latlng) => {
// const { latitude, longitude } = JSON.parse(latlng);
// console.log('flutterLocationLat:', latitude);
// console.log('flutterLocationLng:', longitude);
// };


  window.getFileBytesData = (response) => {

    try {
      console.log('pardedData',JSON.stringify(response));
    } catch (error) {
      console.error('Error parsing JSON', error);
    }
  };

        function sendToFlutter() {
       if(window.FlutterChannel) {
               console.log('GetLocation')

          // window.FlutterChannel.postMessage('GetLocation');
       window.FlutterChannel.postMessage('ProvideProfileImageFormData');
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
