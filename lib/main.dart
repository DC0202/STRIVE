import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:dio/dio.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strive/signUp.dart';
import 'package:strive/splashScreen.dart';

import 'values.dart';

Future<SharedPreferences> sharedPreferencesGlobal =
    SharedPreferences.getInstance();

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'STRIVE',
    description: 'GPS Task',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

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
      initialNotificationTitle: 'STRIVE',
      initialNotificationContent: 'GPS Task',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // for (;;) {}
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await _getCurrentPosition();
    AndroidBatteryInfo? batteryData =
        await BatteryInfoPlugin().androidBatteryInfo;
    Map<String, dynamic> formData = {
      "user_id": sharedPreferences.getInt(spUserId),
      "battery_percentage": batteryData!.batteryLevel,
      "battery_status": batteryData.health.toString(),
      "lat": latLocation,
      "long": longLocation,
      "sample_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    debugPrint(formData.toString());
    try {
      await Dio().post("$url/location",
          data: formData, options: Options(contentType: "application/json"));
    } on DioException catch (e) {
      debugPrint(e.response!.data.toString());
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
  await Permission.phone.request();
  await Permission.location.request();
  await Permission.notification.request();
  await Permission.locationAlways.request();
  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await askPermission();
  await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(spUserId)) {
        setState(() {
          userid = prefs.getInt(spUserId)!;
        });
      }
      if (prefs.containsKey(spEmail)) {
        setState(() {
          email = prefs.getString(spEmail)!;
        });
      }
      if (prefs.containsKey(spImeiNo)) {
        setState(() {
          imei = prefs.getString(spImeiNo)!;
        });
      }
      if (prefs.containsKey(spUserId)) {
        setState(() {
          userid = prefs.getInt(spUserId)!;
          imei = prefs.getString(spImeiNo)!;
          debugPrint("PID: $userid");
          service.startService();
        });
        if (imei != '') {
          setState(() {
            checkPID = !checkPID;
          });
        }
      }
      setState(() {
        loading = false;
      });
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return loading
        ? SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : MaterialApp(
            title: 'CARE',
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                elevation: 0,
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
            ),
            debugShowCheckedModeBanner: false,
            home: checkPID ? const SplashScreen() : const SignUp(),
          );
  }
}
