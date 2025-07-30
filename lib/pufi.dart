import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart' show AppTrackingTransparency, TrackingStatus;
import 'package:appsflyer_sdk/appsflyer_sdk.dart' show AppsFlyerOptions, AppsflyerSdk;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as bananaTz;
import 'package:timezone/timezone.dart' as bananaTz;

import 'main.dart' show FILT;

@pragma('vm:entry-point')
Future<void> _gorillaCoconut(RemoteMessage msg) async {
  print("BANANA MESSAGE: ${msg.messageId}");
  print("BANANA DATA: ${msg.data}");
}

// FCM токен канал
class BananaTokenPipe {
  static const MethodChannel _chimp = MethodChannel('com.example.fcm/token');
  static void peel(Function(String t) onBanana) {
    _chimp.setMethodCallHandler((call) async {
      if (call.method == 'setToken') {
        final String t = call.arguments as String;
        onBanana(t);
      }
    });
  }
}

class MonkeyWebJungle extends StatefulWidget {
  String treeUrl;
  MonkeyWebJungle(this.treeUrl, {super.key});
  @override
  State<MonkeyWebJungle> createState() => _MonkeyWebJungleState(treeUrl);
}

class _MonkeyWebJungleState extends State<MonkeyWebJungle> {
  _MonkeyWebJungleState(this._bananaUrl);

  late InAppWebViewController _gorilla;
  String? _bananaSeed;
  String? _chimpToken;
  String? _slothId;
  String? _lemurInstance;
  String? _parrotPlatform;
  String? _orangOs;
  String? _snakeVersion;
  String? _koalaLang;
  String? _kangarooZone;
  bool _toucanPush = true;
  bool _pandaLoading = false;
  var _rhinoBlock = true;
  final List<ContentBlocker> _zebraBlockers = [];
  String _bananaUrl;

  @override
  void initState() {
    super.initState();



    _zebraBlockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".cookie", resourceType: [
        ContentBlockerTriggerResourceType.RAW
      ]),
      action: ContentBlockerAction(
          type: ContentBlockerActionType.BLOCK, selector: ".notification"),
    ));

    _zebraBlockers.add(ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".cookie", resourceType: [
        ContentBlockerTriggerResourceType.RAW
      ]),
      action: ContentBlockerAction(
          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
          selector: ".privacy-info"),
    ));

    _zebraBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert")));

    FirebaseMessaging.onBackgroundMessage(_gorillaCoconut);
    _initPandaATT();
    _initGiraffeFlyer();
    _setupParrotChannel();
    _initIguanaInfo();
    _initSlothFCM();

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (msg.data['uri'] != null) {
        _swingToTree(msg.data['uri'].toString());
      } else {
        _resetTree();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      if (msg.data['uri'] != null) {
        _swingToTree(msg.data['uri'].toString());
      } else {
        _resetTree();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _initPandaATT();
    });

    Future.delayed(const Duration(seconds: 6), () {
      _bananaLaunch();
    });

    // FCM токен слушатель через TokenPipe
    BananaTokenPipe.peel((tok) {
      setState(() {
        _chimpToken = tok;
      });
    });
  }

  void _setupParrotChannel() {
    MethodChannel('com.example.fcm/notification').setMethodCallHandler((call) async {
      if (call.method == "onNotificationTap") {
        final Map<String, dynamic> jungleData = Map<String, dynamic>.from(call.arguments);
        if (jungleData["uri"] != null && !jungleData["uri"].contains("Нет URI")) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MonkeyWebJungle(jungleData["uri"])),
                (route) => false,
          );
        }
      }
    });
  }

  void _swingToTree(String bananaUri) async {
    if (_gorilla != null) {
      await _gorilla.loadUrl(
        urlRequest: URLRequest(url: WebUri(bananaUri)),
      );
    }
  }

  void _resetTree() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (_gorilla != null) {
        _gorilla.loadUrl(
          urlRequest: URLRequest(url: WebUri(_bananaUrl)),
        );
      }
    });
  }

  Future<void> _initSlothFCM() async {
    FirebaseMessaging m = FirebaseMessaging.instance;
    NotificationSettings s = await m.requestPermission(alert: true, badge: true, sound: true);
    _chimpToken = await m.getToken();
  }

  Future<void> _initPandaATT() async {
    final TrackingStatus s = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (s == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 1000));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("GORILLA UUID: $uuid");
  }

  AppsflyerSdk? _toucan;
  String _parrotId = "";
  String _giraffeConv = "";

  void _initGiraffeFlyer() {
    final AppsFlyerOptions opts = AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6745261464",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 0,
    );
    _toucan = AppsflyerSdk(opts);
    _toucan?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    _toucan?.startSDK(
      onSuccess: () => print("GiraffeFlyer OK"),
      onError: (int code, String msg) => print("GiraffeFlyer ERR $code $msg"),
    );
    _toucan?.onInstallConversionData((res) {
      setState(() {
        _giraffeConv = res.toString();
        _parrotId = res['payload']['af_status'].toString();
      });
    });
    _toucan?.getAppsFlyerUID().then((value) {
      setState(() {
        _parrotId = value.toString();
      });
    });
  }

  Future<void> _bananaLaunch() async {
    print("GIRAFFE DATA: $_giraffeConv");
    final coconut = {
      "content": {
        "af_data": "$_giraffeConv",
        "af_id": "$_parrotId",
        "fb_app_name": "amonwar",
        "app_name": "amonwar",
        "deep": null,
        "bundle_identifier": "com.caswar.casinowar.casinowar",
        "app_version": "1.0.0",
        "apple_id": "6749231714",
        "fcm_token": _chimpToken ?? "no_banana_token",
        "device_id": _slothId ?? "default_sloth_id",
        "instance_id": _lemurInstance ?? "default_lemur_id",
        "platform": _parrotPlatform ?? "unknown_jungle",
        "os_version": _orangOs ?? "default_orang_os",
        "app_version": _snakeVersion ?? "default_snake_ver",
        "language": _koalaLang ?? "en",
        "timezone": _kangarooZone ?? "UTC",
        "push_enabled": _toucanPush,
        "useruid": "$_parrotId",
      },
    };

    final coconutString = jsonEncode(coconut);
    print("My coconut: $coconutString");
    await _gorilla.evaluateJavascript(
      source: "sendRawData(${jsonEncode(coconutString)});",
    );
  }

  Future<void> _initIguanaInfo() async {
    try {
      final iguana = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await iguana.androidInfo;
        _slothId = android.id;
        _parrotPlatform = "android";
        _orangOs = android.version.release;
      } else if (Platform.isIOS) {
        final ios = await iguana.iosInfo;
        _slothId = ios.identifierForVendor;
        _parrotPlatform = "ios";
        _orangOs = ios.systemVersion;
      }
      final capybara = await PackageInfo.fromPlatform();
      _snakeVersion = capybara.version;
      _koalaLang = Platform.localeName.split('_')[0];
      _kangarooZone = bananaTz.local.name;
      _lemurInstance = "lemur-unique-123";
      if (_gorilla != null) {
        // Можно вызвать push данных сюда если нужно
      }
    } catch (e) {
      debugPrint("Iguana error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupParrotChannel();
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              disableDefaultErrorPage: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: true,
              useOnDownloadStart: true,

              javaScriptCanOpenWindowsAutomatically: true,
            ),
            initialUrlRequest: URLRequest(url: WebUri(_bananaUrl)),
            onWebViewCreated: (controller) {
              _gorilla = controller;
              _gorilla.addJavaScriptHandler(
                  handlerName: 'onJungleResponse',
                  callback: (args) {
                    print("JUNGLE ARGS: $args");
                    return args.reduce((curr, next) => curr + next);
                  });
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                source: "console.log('Monkey in the tree!');",
              );
              // Можно вызывать _bananaLaunch тут.
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_pandaLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}