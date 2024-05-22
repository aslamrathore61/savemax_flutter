import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Component/DrawerMenuItem.dart';
import '../Component/buttons/socal_button.dart';
import '../Config.dart';
import '../Utils/constants.dart';
import '../main.dart';
import '../model/native_item.dart';
import 'NoInternetConnectionPage.dart';

/// Flutter code sample for [TabBar].

class TabBarPage extends StatefulWidget {
  final NativeItem nativeItem;

  TabBarPage({required this.nativeItem});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late WebViewController _webViewController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    } else {
      handleDeepLink(null);
    }

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
    String deepLinkingURL;

    if (redirectLink != null && redirectLink.isNotEmpty) {
      Uri uri = Uri.parse(redirectLink);
      String segmentPath = uri.path + '?' + uri.query;
      deepLinkingURL = Config.HOME_URL + segmentPath;
    } else {
      deepLinkingURL = Config.HOME_URL;
    }
    setState(() {
      _webViewController.loadRequest(Uri.parse(deepLinkingURL));
    });
  }


  void CallAppIconChangerMethod(String message) async {
    await platform.invokeMethod('AppIconChange', message);
  }

  @override
  void initState() {
    super.initState();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _checkInitialConnectivity();

    setupInteractedMessage();

    _tabController = TabController(
      length: widget.nativeItem.bottom!.length,
      vsync: this,
    );
    _webViewController = WebViewController();
    // Load the initial URL for the first tab
    if (widget.nativeItem.bottom!.isNotEmpty &&
        widget.nativeItem.bottom![0].uRL!.isNotEmpty) {
      _webViewController
          .loadRequest(Uri.parse(widget.nativeItem.bottom![0].uRL!));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index, String url) {
    print('urlrrrr $url = $index');
    if (index == widget.nativeItem.bottom!.length - 1) {
      // Open the drawer if the last tab is selected
      _scaffoldKey.currentState?.openDrawer();

      // Set the tab controller index to the previous tab
      _tabController.index = _tabController.previousIndex;
    } else {
      // Load the URL for the selected tab
      if (url.isNotEmpty) {
        _webViewController.loadRequest(Uri.parse(url));
      }
    }
  }

  Future<void> _checkInitialConnectivity() async {
    _initialConnectivity = await _connectivity.checkConnectivity();
    setState(() {}); // Update the UI after checking initial connectivity
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    return Container(
      margin: EdgeInsets.only(top: statusBarHeight),
      child: Scaffold(
        key: _scaffoldKey,
       /* floatingActionButton: FloatingActionButton(
          onPressed: () {
            CallAppIconChangerMethod(
                ".MainActivityB");
          },
        ),*/
        drawer: Container(
            width: MediaQuery
                .of(context)
                .size
                .width - 74,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.zero, // Remove the corner radius
              color: Colors.white, // Set your desired background color here
            ),
            child: Drawer(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      color: darkGreyColor,
                      padding: EdgeInsets.only(
                          right: 10, left: 10, top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SocalButton(
                              color: Colors.blue.shade800,
                              icon: Icon(Icons.input,
                                  color: Colors.white, size: 16),
                              press: () {
                                // handle this button here
                              },
                              text: "Sign-in".toUpperCase(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Icon(Icons.close),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.nativeItem.side?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return DrawerMenuItem(
                            parenturl: widget.nativeItem.side![index].uRL!,
                            parentID: widget.nativeItem.side![index].id!,
                            base64Icon: widget.nativeItem.side![index].icon!,
                            base64IconMenu:
                            widget.nativeItem.side![index].menuIcon!,
                            subList: widget.nativeItem.side![index].subList!,
                            title: widget.nativeItem.side![index].title!,
                            onTap: (String url, String id) {
                              int index = 0;
                              int foundIndex =
                              -1; // Initialize with -1 to indicate not found
                              widget.nativeItem.bottom?.forEach((element) {
                                print('fjkdjf ${element.id} id  $id');
                                if (element.id == id) {
                                  foundIndex =
                                      index; // Set foundIndex to the current index
                                  return; // Exit the forEach loop
                                }
                                index++;
                              });

                              if (foundIndex != -1) {
                                _tabController.index = foundIndex;
                                _onTabTapped(foundIndex, url);
                              } else {
                                _onTabTapped(0, url);
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
            )),
        body: Column(
          children: [
            Container(
                height: 58,
                width: double.infinity,
                color: greyColor,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        'assets/icons/savemaxdoller.png',
                        width: 27,
                        height: 27,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        height: double.infinity,
                        color: Colors.white,
                        child: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Icon(
                                Icons.location_on,
                                size: 17,
                              ),
                            ),
                            Text(
                              'Toronto',
                              style: TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                        ),
                        height: double.infinity,
                        color: darkGreyColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                CallAppIconChangerMethod(
                                    ".MainActivityA");
                              },
                              child: Padding(
                                padding:
                                EdgeInsets.only(left: 10.0, right: 6.0),
                                child: Icon(Icons.close, size: 16),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 6.0, right: 10.0),
                              child: Icon(
                                Icons.search,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                        flex: 0,
                        child: SizedBox(
                          width: 33,
                        )),
                  ],
                )),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: _initialConnectivity == null
                  ? Center(
                  child:
                  CircularProgressIndicator()) // Show loading indicator while checking initial connectivity
                  : StreamBuilder<ConnectivityResult>(
                stream: _connectivityStream,
                builder: (BuildContext context,
                    AsyncSnapshot<ConnectivityResult> snapshot) {
                  // Check initial connectivity if stream has not emitted any data yet
                  final connectivityResult =
                      snapshot.data ?? _initialConnectivity;

                  if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                      connectivityResult == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (connectivityResult == ConnectivityResult.none) {
                    return Center(
                      child: NoInternetConnectionPage(
                        tryAgain: _checkInitialConnectivity,
                      ),
                    );
                  } else {
                    return WebViewWidget(
                      controller: _webViewController
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..setBackgroundColor(const Color(0x00000000))
                        ..addJavaScriptChannel(
                          'ShareChannel',
                          onMessageReceived: (JavaScriptMessage message) {
                            print('ShareChannelOBJ: ${message.message}');

                          },
                        )
                        ..setNavigationDelegate(
                          NavigationDelegate(
                              onProgress: (int progress) {
                                // Update loading bar.
                              },
                              onPageStarted: (String url) {
                                print('onPageStarted $url');


                              },
                              onPageFinished: (String url) {
                                print('onPageFinished $url');
                              },
                              onWebResourceError: (WebResourceError error) {
                                print('onWebResourceError ${error.errorType} ${error.errorCode} ${error.description}');
                                if (error.errorCode == -2) {
                                  // Reload the WebView on connectivity error
                                  _webViewController.reload();
                                }
                              },
                              
                              onNavigationRequest: (NavigationRequest request) {
                                print('urlcheckvalue ${request.url}');

                                if (request.url.startsWith('share://')) {
                                  // Extract the text to be shared
                                  String shareText = request.url.replaceFirst('share://', '');

                                  print('sharetextvalue ${shareText}');
                                  // Handle sharing
                                  // You can use a package like share_plus to share the text
                                  // See https://pub.dev/packages/share_plus for details
                                  // Make sure to add the necessary permissions in AndroidManifest.xml and Info.plist
                                  // for Android and iOS respectively
                                  return NavigationDecision.prevent;
                                }
                                return NavigationDecision.navigate;


                                // This is where you handle the navigation request
                             /*   if (request.url.startsWith('https://savemax.com')) {


                                  print('Allowing navigation to ${request.url}');
                                  return NavigationDecision.navigate;
                                } else {
                                  print(
                                      'Blocking navigation to ${request.url}');
                                  return NavigationDecision.prevent;
                                }*/
                              }

                          ),
                        ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey, // Top border color for the TabBar
                width: 0.5, // Width of the top border
              ),
            ),
          ),
          child: TabBar(
            labelColor: Colors.red,
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
            labelStyle: TextStyle(fontSize: 13),
            splashFactory: NoSplash.splashFactory,
            onTap: (index) {
              final url = widget.nativeItem.bottom![index].uRL!;
              _onTabTapped(index, url);
            },
            tabs: widget.nativeItem.bottom!.map((item) {
              final bytes = base64Decode(item.icon!);
              ImageProvider _imageProvider = MemoryImage(bytes);
              return Tab(
                icon: ImageIcon(_imageProvider),
                text: item.title,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }


}


