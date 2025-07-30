import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:casinowar/pufi.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as memeTz;
import 'package:timezone/timezone.dart' as memeTz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  memeTz.initializeTimeZones();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_shrekBackgroundMessage);
  final prefs = await _DonkeyPrefs.instance();
  final seen = prefs.getBool('onions') ?? false;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SwampScreen(),
  ));
}

// --- BACKGROUND SHREK ---
@pragma('vm:entry-point')
Future<void> _shrekBackgroundMessage(RemoteMessage msg) async {}

// --- TokenChannel для получения FCM токена ---
class TokenChannel {
  static const MethodChannel _c = MethodChannel('com.example.fcm/token');
  static void listen(Function(String token) onToken) {
    _c.setMethodCallHandler((call) async {
      if (call.method == 'setToken') {
        final String token = call.arguments as String;
        onToken(token);
      }
    });
  }
}

// --- ПРЕФЕРЕНСИИ ДОНКИ ---
class _DonkeyPrefs {
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }
}

// --- ЭКРАН ЛУКА ---
class OnionScreen extends StatefulWidget {
  const OnionScreen({super.key});
  @override
  State<OnionScreen> createState() => _OnionScreenState();
}

class _OnionScreenState extends State<OnionScreen> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    super.initState();
  }

  Future<void> _eatOnion() async {
    final prefs = await _DonkeyPrefs.instance();
    await prefs.setBool('onions', true);
  }

  void _goToSwamp() async {
    await _eatOnion();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SwampScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.green.shade800,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.limeAccent.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_nature, size: 56, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'Why do we need your onions?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Onions have layers. So does your data. We use your onions to make life tastier and give you the freshest swamps. Your onions are safe with us!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontSize: 14),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.green.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _goToSwamp,
                  child: const Text('Peel the Onion'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You can always eat more onions in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ОСНОВНОЙ ЭКРАН БОЛОТА ---
class SwampScreen extends StatefulWidget {
  const SwampScreen({super.key});
  @override
  State<SwampScreen> createState() => _SwampScreenState();
}

class _SwampScreenState extends State<SwampScreen> with WidgetsBindingObserver {
  InAppWebViewController? _donkeyWeb;
  final String _swampUrl = "https://settings.phonewgame.click/";
  final _fionaDevice = _FionaDevice();
  final _pussTracker = _PussInBootsTracker();
  DateTime? _ogreSleep;
  bool _showSwamp = false;
  double _mudProgress = 0.0;
  late Timer _mudTimer;

  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Слушаем FCM токен через канал
    TokenChannel.listen((token) {
      setState(() {
        _fcmToken = token;
      });
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    _pussTracker.start(() => setState(() {}));
    _fionaDevice.init();
    _listenDragon();
    _whistleToDonkey();
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _showSwamp = true);
    });
    _startMud();
  }

  void _startMud() {
    int cnt = 0;
    _mudProgress = 0.0;
    _mudTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        cnt++;
        _mudProgress = cnt / 80;
        if (_mudProgress >= 1.0) {
          _mudProgress = 1.0;
          _mudTimer.cancel();
        }
      });
    });
  }

  void _listenDragon() {
    FirebaseMessaging.onMessage.listen((msg) {
      final url = msg.data['uri'];
      if (url != null) {
        _goToUrl(url.toString());
      } else {
        _resetSwamp();
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final url = msg.data['uri'];
      if (url != null) {
        _goToUrl(url.toString());
      } else {
        _resetSwamp();
      }
    });
  }

  void _whistleToDonkey() {
    MethodChannel('com.example.fcm/notification').setMethodCallHandler((call) async {
      if (call.method == "onNotificationTap") {
        final Map<String, dynamic> carrots = Map<String, dynamic>.from(call.arguments);
        final url = carrots["uri"];
        if (url != null && url.toString().isNotEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MonkeyWebJungle(url)),
                (route) => false,
          );
        }
      }
    });
  }

  void _goToUrl(String url) async {
    if (_donkeyWeb != null) {
      await _donkeyWeb!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
  }

  void _resetSwamp() async {
    Future.delayed(const Duration(seconds: 3), () {
      if (_donkeyWeb != null) {
        _donkeyWeb!.loadUrl(urlRequest: URLRequest(url: WebUri(_swampUrl)));
      }
    });
  }

  Future<void> _sendOnion() async {
    final data = _fionaDevice.packet(fcmToken: _fcmToken);
    if (_donkeyWeb != null) {
      await _donkeyWeb!.evaluateJavascript(source: '''
        localStorage.setItem('app_data', JSON.stringify(${jsonEncode(data)}));
      ''');
    }
  }

  Future<void> _sendPuss() async {
    final data = {
      "content": {
        "af_data": _pussTracker.hat,
        "af_id": _pussTracker.boot,
        "fb_app_name": "amonwar",
        "app_name": "amonwar",
        "deep": null,
        "bundle_identifier": "com.caswar.casinowar.casinowar",
        "app_version": "1.0.0",
        "apple_id": "6749231714",
        "fcm_token": _fcmToken,
        "device_id": _fionaDevice.did ?? "no_donkey",
        "instance_id": _fionaDevice.sid ?? "no_waffle",
        "platform": _fionaDevice.pt ?? "no_biscuit",
        "os_version": _fionaDevice.osv ?? "no_teapot",
        "app_version": _fionaDevice.av ?? "no_frog",
        "language": _fionaDevice.lg ?? "en",
        "timezone": _fionaDevice.tz ?? "UTC",
        "push_enabled": _fionaDevice.pe,
        "useruid": _pussTracker.boot,
      },
    };
    final jsonString = jsonEncode(data);

    print("JJSSOO "+jsonString.toString());
    if (_donkeyWeb != null) {
      await _donkeyWeb!.evaluateJavascript(
        source: "sendRawData(${jsonEncode(jsonString)});",
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ogreSleep = DateTime.now();
    }
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS && _ogreSleep != null) {
        final now = DateTime.now();
        final dt = now.difference(_ogreSleep!);
        if (dt > const Duration(minutes: 25)) {
          _reloadSwamp();
        }
      }
      _ogreSleep = null;
    }
  }

  void _reloadSwamp() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SwampScreen(),
        ),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mudTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _whistleToDonkey();
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Stack(
        children: [
          if (_showSwamp)
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
              initialUrlRequest: URLRequest(url: WebUri(_swampUrl)),
              onWebViewCreated: (controller) {
                _donkeyWeb = controller;
                _donkeyWeb!.addJavaScriptHandler(
                  handlerName: 'onServerResponse',
                  callback: (args) {
                    print("JS args: $args");
                    print("From the JavaScript side:");
                    print("ResRes" + args[0]['savedata'].toString());
                    if (args[0]['savedata'].toString() == "false") {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    }
                    return args.reduce((curr, next) => curr + next);
                  },
                );
              },
              onLoadStart: (controller, url) {
                setState(() {});
              },
              onLoadStop: (controller, url) async {
                await controller.evaluateJavascript(
                  source: "console.log('Swamp loaded!');",
                );
                await _sendOnion();
                await _sendPuss();
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },
            ),
          if (!_showSwamp)
            const Center(child: ShrekText()),
        ],
      ),
    );
  }
}



// --- АНИМИРОВАННЫЙ ТЕКСТ ---
class ShrekText extends StatefulWidget {
  const ShrekText();
  @override
  State<ShrekText> createState() => _ShrekTextState();
}

class _ShrekTextState extends State<ShrekText> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _colorAnim = ColorTween(begin: Colors.lime, end: Colors.green).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context, child) => Center(
        child: Text(
          "war casino",
          style: TextStyle(
            color: _colorAnim.value,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// --- Девайс Фионы ---
class _FionaDevice {
  String? did;
  String? sid;
  String? pt;
  String? osv;
  String? av;
  String? lg;
  String? tz;
  bool pe = true;

  Future<void> init() async {
    final di = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final data = await di.androidInfo;
      did = data.id;
      pt = "android";
      osv = data.version.release;
    } else if (Platform.isIOS) {
      final data = await di.iosInfo;
      did = data.identifierForVendor;
      pt = "ios";
      osv = data.systemVersion;
    }
    final appInfo = await PackageInfo.fromPlatform();
    av = appInfo.version;
    lg = Platform.localeName.split('_')[0];
    tz = _swampZone();
    sid = "swamp-${DateTime.now().millisecondsSinceEpoch}";
  }

  Map<String, dynamic> packet({String? fcmToken}) {
    return {
      "fcm_token": fcmToken,
      "device_id": did ?? 'missing_fiona',
      "app_name": "amonwars",
      "instance_id": sid ?? 'missing_sid',
      "platform": pt ?? 'missing_pt',
      "os_version": osv ?? 'missing_osv',
      "app_version": av ?? 'missing_av',
      "language": lg ?? 'en',
      "timezone": tz ?? 'UTC',
      "push_enabled": pe,
    };
  }
}

String _swampZone() {
  try {
    return memeTz.local.name;
  } catch (_) {
    return 'SWAMP';
  }
}

// --- Кот в сапогах (трекер) ---
class _PussInBootsTracker {
  AppsflyerSdk? _af;
  String boot = "";
  String hat = "";

  void start(VoidCallback cb) {
    final o = AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6749231714",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 0, // ATT ждать не надо!
    );
    _af = AppsflyerSdk(o);
    _af?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    _af?.startSDK();
    _af?.onInstallConversionData((res) {
      hat = res.toString();
      cb();
    });
    _af?.getAppsFlyerUID().then((val) {
      boot = val.toString();
      cb();
    });
  }
}