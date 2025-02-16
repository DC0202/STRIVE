import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:auresia/homePage.dart';
import 'package:auresia/transitionAnimation.dart';
import 'package:auresia/values.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool initialize = true;
  funCall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        initialize = !initialize;
        userId = prefs.getInt(spUserId)!;
      });
    }
    await askPermission();
  }

  Future<bool> askPermission() async {
    if (Platform.isAndroid) {
      await Permission.phone.request();
      await Permission.location.request();
    } else if (Platform.isIOS) {
      await Permission.locationWhenInUse.request();
      await Permission.locationAlways.request();
    }
    await Permission.notification.request();
    await Permission.locationAlways.request();
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await funCall();
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          FadeRoute(page: const HomePage()),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6FA),
      body: !initialize
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Container(
              color: const Color(0xFFE6E6FA),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Text(
                  'AURESIA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36.sp,
                  ),
                ),
              ),
            ),
    );
  }
}
