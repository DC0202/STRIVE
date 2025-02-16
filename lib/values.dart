import 'package:flutter_background_service/flutter_background_service.dart';

var service = FlutterBackgroundService();

bool checkUID = false;
double latLocation = 0.0;
double longLocation = 0.0;

String url = "http://socolab-phi.luddy.indiana.edu:13695";

// SharedPreferences Keys
String spUserId = 'user_id';
String sppassword = 'password';

// SharedPreferences Values
int userId = 0;
String password = '';
String setNotificationToken = "";
