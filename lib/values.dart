import 'package:flutter_background_service/flutter_background_service.dart';

var service = FlutterBackgroundService();

bool checkPID = false;
double latLocation = 0.0;
double longLocation = 0.0;

String url = "http://socolab-phi.luddy.indiana.edu:13691";

// SharedPreferences Keys
String spImeiNo = 'imei';
String spEmail = 'email';
String spUserId = 'user_id';

// SharedPreferences Values
String imei = '';
String email = '';
int userid = 0;

String? password = "iustrive@";
