import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strive/homePage.dart';
import 'package:strive/transitionAnimation.dart';
import 'package:strive/values.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool initialize = true;
  funCall() async {
    await askPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        initialize = !initialize;
        userid = prefs.getInt(spUserId)!;
        imei = prefs.getString(spImeiNo)!;
        email = prefs.getString(spEmail)!;
      });
    }
  }

  Future<bool> askPermission() async {
    await Permission.phone.request();
    await Permission.location.request();
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
        Navigator.of(context)
            .pushReplacement(FadeRoute(page: const HomePage()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7F3F9),
      body: initialize
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : Container(
              color: const Color(0xFFD7F3F9),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Text(
                  'S.T.R.I.V.E.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                  ),
                ),
              ),
            ),
    );
  }
}
