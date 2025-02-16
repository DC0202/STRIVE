import UIKit
import Flutter
import CoreLocation
import AppTrackingTransparency
import AdSupport

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  var locationManager: CLLocationManager?
  var lastSentTime: Date?

  // MethodChannel for App Tracking Transparency
  var trackingChannel: FlutterMethodChannel?

  // This method channel will be used to communicate with Flutter.
  var locationChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up the platform channel for location updates.
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    locationChannel = FlutterMethodChannel(name: "com.locationBackgroundService/location",
                                           binaryMessenger: controller.binaryMessenger)

    locationChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "startLocationService" {
        self?.startLocationService()
        result(true)
      } else if call.method == "stopLocationService" {
        self?.stopLocationService()
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Set up the platform channel for tracking permission requests.
    trackingChannel = FlutterMethodChannel(name: "com.yourapp/tracking_permission",
                                           binaryMessenger: controller.binaryMessenger)
    trackingChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "requestTrackingPermission" {
        self.requestTrackingPermission(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Function to request App Tracking Transparency permission
  private func requestTrackingPermission(result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized:
          result("authorized")
        case .denied:
          result("denied")
        case .notDetermined:
          result("notDetermined")
        case .restricted:
          result("restricted")
        @unknown default:
          result("unknown")
        }
      }
    } else {
      result("unavailable")
    }
  }

  func startLocationService() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestAlwaysAuthorization()
    locationManager?.startUpdatingLocation()

    // Ensure background location updates are enabled.
    if let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String], backgroundModes.contains("location") {
      locationManager?.allowsBackgroundLocationUpdates = true
    }

    locationManager?.pausesLocationUpdatesAutomatically = false
    print("Location service started.")
  }

  func stopLocationService() {
    locationManager?.stopUpdatingLocation()
    locationManager?.allowsBackgroundLocationUpdates = false
    locationManager = nil
    print("Location service stopped.")
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    let now = Date()
    if let lastSentTime = lastSentTime, now.timeIntervalSince(lastSentTime) < 60 {
      return
    }
    lastSentTime = now

    // Pass location data to Flutter through the platform channel.
    let locationData: [String: Any] = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude
    ]

    locationChannel?.invokeMethod("locationUpdate", arguments: locationData)
  }
}
