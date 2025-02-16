import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:auresia/values.dart';

import 'signUp.dart';
import 'splashScreen.dart';
import 'transitionAnimation.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(spUserId)) {
        setState(() {
          userId = prefs.getInt(spUserId)!;
        });
      }
      if (prefs.containsKey(spUserId)) {
        setState(() {
          userId = prefs.getInt(spUserId)!;
          service.startService();
        });
        if (userId != 0) {
          setState(() {
            checkUID = !checkUID;
          });
        }
      }
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          FadeRoute(page: checkUID ? const SplashScreen() : const SignUp()),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA), // Light Lavender
              Color(0xFFD8BFD8), // Thistle
              Color(0xFFC4C3D0), // Lavender Gray
              Color(0xFFB0B7C6), // Light Slate Gray
              Color(0xFF8A8DA6), // Dark Lavender
            ],
            stops: [0.1, 0.3, 0.5, 0.7, 0.9],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/auresia_logo.png',
            width: 18.h,
            height: 18.h,
          ),
        ),
      ),
    );
  }
}
