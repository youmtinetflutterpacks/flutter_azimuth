import Flutter
import UIKit
import CoreLocation

public class SwiftFlutterAzimuthPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var eventSink: FlutterEventSink?
  private var isUpdatingHeading = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftFlutterAzimuthPlugin()

    let versionChannel = FlutterMethodChannel(name: "flutter_azimuth", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: versionChannel)

    let sensorChannel = FlutterMethodChannel(name: "checkDeviceSensors", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: sensorChannel)

    let eventChannel = FlutterEventChannel(name: "azimuthStream", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getSensors":
      result(checkSensors())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - FlutterStreamHandler

  public func onListen(arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = eventSink
    startHeadingUpdates()
    return nil
  }

  public func onCancel(arguments: Any?) -> FlutterError? {
    stopHeadingUpdates()
    eventSink = nil
    return nil
  }

  // MARK: - Sensor handling

  private func checkSensors() -> Int {
    return CLLocationManager.headingAvailable() ? 1 : 0
  }

  private func startHeadingUpdates() {
    guard CLLocationManager.headingAvailable() else {
      eventSink?(FlutterError(code: "HEADING_UNAVAILABLE", message: "Device does not support heading updates.", details: nil))
      return
    }

    let manager = ensureLocationManager()
    let status = currentAuthorizationStatus()

    switch status {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .restricted, .denied:
      eventSink?(FlutterError(code: "PERMISSION_DENIED", message: "Heading access denied. Grant location permission to receive heading updates.", details: nil))
    default:
      guard !isUpdatingHeading else { return }
      manager.startUpdatingHeading()
      isUpdatingHeading = true
    }
  }

  private func stopHeadingUpdates() {
    guard let manager = locationManager, isUpdatingHeading else { return }
    manager.stopUpdatingHeading()
    isUpdatingHeading = false
  }

  private func ensureLocationManager() -> CLLocationManager {
    if let manager = locationManager {
      return manager
    }

    let manager = CLLocationManager()
    manager.delegate = self
    manager.headingFilter = kCLHeadingFilterNone
    locationManager = manager
    return manager
  }

  private func currentAuthorizationStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager?.authorizationStatus ?? .notDetermined
    } else {
      return CLLocationManager.authorizationStatus()
    }
  }

  // MARK: - CLLocationManagerDelegate

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard eventSink != nil else { return }

    let status = currentAuthorizationStatus()
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      startHeadingUpdates()
    }
  }

  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    locationManagerDidChangeAuthorization(manager)
  }

  public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard newHeading.headingAccuracy >= 0 else { return }

    let heading = (newHeading.magneticHeading.truncatingRemainder(dividingBy: 360) + 360)
      .truncatingRemainder(dividingBy: 360)
    let normalizedHeading = Int(heading.rounded())

    eventSink?(normalizedHeading)
  }

  public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }

  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    eventSink?(FlutterError(code: "HEADING_ERROR", message: error.localizedDescription, details: nil))
  }
}
