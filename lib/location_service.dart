import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:auresia/values.dart';

class LocationService {
  static const platform =
      MethodChannel('com.locationBackgroundService/location');
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  LocationService() {
    platform.setMethodCallHandler(_handleLocationUpdates);
  }

  Future<bool> initLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    location.enableBackgroundMode(enable: true);

    await platform.invokeMethod('startLocationService');
    return true;
  }

  Future<void> stopLocationService() async {
    try {
      await platform.invokeMethod('stopLocationService');
    } on PlatformException catch (e) {
      print("Failed to stop location service: '${e.message}'.");
    }
  }

  Future<void> _handleLocationUpdates(MethodCall call) async {
    if (call.method == "locationUpdate") {
      final double latitude = call.arguments["latitude"];
      final double longitude = call.arguments["longitude"];

      await sendLocationData(latitude, longitude);
    }
  }

  Future<void> sendLocationData(double latitude, double longitude) async {
    if (userId != 0) {
      try {
        Map<String, dynamic> formData = {
          "user_id": userId,
          "lat": latitude,
          "long": longitude,
          "sample_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
          "notification_token": setNotificationToken,
        };
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
        print(e.toString());
      }
    }
  }
}
