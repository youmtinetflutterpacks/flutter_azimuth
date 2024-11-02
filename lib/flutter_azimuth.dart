import 'dart:async';
import 'package:flutter/services.dart';

class FlutterAzimuth {
  /// Stream Azimuth
  static Stream<int?>? _azimuthValue;

  /// method channel checkDeviceSensors
  static const MethodChannel _channel = MethodChannel('checkDeviceSensors');

  /// method channel azimuthStream
  static const EventChannel _eventChannel = EventChannel('azimuthStream');

  /// method channel checkSensors
  static Future<int?> get checkSensors async {
    final int? haveSensor = await _channel.invokeMethod('getSensors');
    return haveSensor;
  }

  /// method channel azimuthStream
  static Stream<int?>? get azimuthStream {
    _azimuthValue ??= _eventChannel.receiveBroadcastStream().map<int?>((value) => value);

    return _azimuthValue;
  }
}
