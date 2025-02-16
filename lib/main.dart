import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:auresia/launchScreen.dart';
import 'package:auresia/location_service.dart';
import 'package:auresia/values.dart';
import 'package:http/http.dart' as http;

Future<SharedPreferences> sharedPreferencesGlobal =
    SharedPreferences.getInstance();
final LocationService _locationService = LocationService();

// MethodChannel to request App Tracking Transparency permission from iOS
const MethodChannel trackingPermissionChannel =
    MethodChannel('com.yourapp/tracking_permission');

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'AURESIA',
    description: 'GPS Task',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AURESIA',
      initialNotificationContent: 'GPS Task',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt(spUserId) != null) {
      await _getCurrentPosition();
      String? token = sharedPreferences.getString('notification_token');
      Map<String, dynamic> formData = {
        "user_id": sharedPreferences.getInt(spUserId),
        "lat": latLocation,
        "long": longLocation,
        "sample_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "notification_token": token,
      };
      try {
        var link = Uri.parse('$url/location');
        var response = await http.post(link,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(formData));

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("DATA SENT");
        } else {
          print('Some Error');
        }
      } catch (e) {
        print('Error in onStart method: $e');
      }
    }
  });
}

Future<void> _getCurrentPosition() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.reload();
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position) {
    latLocation = position.latitude;
    longLocation = position.longitude;
  }).catchError((e) {
    debugPrint(e);
  });
}

Future<bool> askPermission() async {
  if (Platform.isAndroid) {
    await Permission.phone.request();
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.notification.request();
  } else if (Platform.isIOS) {
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();
    await Permission.notification.request();
  }
  if (Platform.isAndroid) {
    if (!await Permission.phone.isGranted ||
        !await Permission.notification.isGranted ||
        !await Permission.locationAlways.isGranted) {
      openAppSettings();
    }
  }

  return true;
}

// Method to request App Tracking Transparency permission
Future<bool> requestTrackingPermission() async {
  try {
    final result = await trackingPermissionChannel
        .invokeMethod('requestTrackingPermission');
    // print("Tracking Permission Status: $result");
    return result == 'authorized';
  } on PlatformException catch (e) {
    print("Failed to get tracking permission: ${e.message}");
    return false;
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Future.delayed(Duration(seconds: 1));
//   if (await requestTrackingPermission()) {
//     await Firebase.initializeApp();
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         runApp(const MyApp());
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       print("onMessageOpenedApp: $message");
//       runApp(const MyApp());
//     });

//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       print("New Token: $newToken");
//     });
//     runApp(const MyApp());
//   }
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      runApp(const MyApp());
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp: $message");
    runApp(const MyApp());
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("New Token: $newToken");
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _appInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // bool isInitialized = prefs.getBool('isInitialized') ?? false;
      // if (!isInitialized) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          !_appInitialized) {
        await initializeApp();
      }
      // } else {
      //   setState(() {
      //     _appInitialized = true;
      //   });
      // }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && !_appInitialized) {
      initializeApp();
    }
  }

  Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isInitialized = prefs.getBool('isInitialized') ?? false;
    if (Platform.isAndroid) {
      await askPermission();
      final notificationService = NotificationService();
      await notificationService.requestPermissionAndHandleToken();
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      await initializeService().then((_) async {
        // await prefs.setBool('isInitialized', true);
        setState(() {
          _appInitialized = true;
        });
      });
    } else if (await requestTrackingPermission() && Platform.isIOS) {
      await askPermission();
      final notificationService = NotificationService();
      await notificationService.requestPermissionAndHandleToken();
      bool val = await _locationService.initLocationService();
      if (val) {
        // await prefs.setBool('isInitialized', true);
        setState(() {
          _appInitialized = true;
        });
      }
      // setState(() {
      //   _appInitialized = true;
      // });
    } else {
      print("Permissions not given");
      await askPermission();
      final notificationService = NotificationService();
      await notificationService.requestPermissionAndHandleToken();
      bool val = await _locationService.initLocationService();
      if (val) {
        // await prefs.setBool('isInitialized', true);
        setState(() {
          _appInitialized = true;
        });
      }
      // setState(() {
      //   _appInitialized = true;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'CARE',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        ),
        debugShowCheckedModeBanner: false,
        home: !_appInitialized
            ? const Scaffold(
                backgroundColor: Color(0xFFE6E6FA),
                body: Center(child: CircularProgressIndicator()),
              )
            : const LaunchScreen(),
      );
    });
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> requestPermissionAndHandleToken() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      print("FCM Token: $token");
      if (token != null) {
        setNotificationToken = token;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('notification_token', token);
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
