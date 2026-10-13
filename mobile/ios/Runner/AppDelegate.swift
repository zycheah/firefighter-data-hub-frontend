import CoreLocation
import Flutter
import UIKit
import UserNotifications
import flutter_foreground_task

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate {
  // Lets iOS relaunch the app after termination so tracking can resume.
  private let relaunchLocationManager = CLLocationManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    appendTrackingDiagnostics(
      "native launch byLocation=\(launchOptions?[.location] != nil) "
        + "appState=\(application.applicationState.rawValue)"
    )
    relaunchLocationManager.delegate = self
    startRelaunchMonitoringIfAuthorized()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func startRelaunchMonitoringIfAuthorized() {
    guard relaunchLocationManager.authorizationStatus == .authorizedAlways,
      CLLocationManager.significantLocationChangeMonitoringAvailable()
    else { return }
    relaunchLocationManager.startMonitoringSignificantLocationChanges()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    startRelaunchMonitoringIfAuthorized()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    appendTrackingDiagnostics("native significant location change")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    appendTrackingDiagnostics("native significant location error: \(error.localizedDescription)")
  }

  /// Shares the log file with the Dart `TrackingDiagnostics`.
  private func appendTrackingDiagnostics(_ event: String) {
    guard
      let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
      let data = "\(ISO8601DateFormatter().string(from: Date())) \(event)\n".data(using: .utf8)
    else { return }
    let url = dir.appendingPathComponent("tracking_diagnostics.log")
    if let handle = try? FileHandle(forWritingTo: url) {
      handle.seekToEndOfFile()
      handle.write(data)
      handle.closeFile()
    } else {
      try? data.write(to: url)
    }
  }
}
