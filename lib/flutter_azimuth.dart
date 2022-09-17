import 'dart:async';
import 'package:flutter/services.dart';

class FlutterAzimuth {
  static Stream<int?>? _azimuthValue;

  static const MethodChannel _channel = MethodChannel('checkDeviceSensors');

  static const EventChannel _eventChannel = EventChannel('azimuthStream');

  static Future<int?> get checkSensors async {
    final int? haveSensor = await _channel.invokeMethod('getSensors');
    return haveSensor;
  }

  static Stream<int?>? get azimuthStream {
    _azimuthValue ??=
        _eventChannel.receiveBroadcastStream().map<int?>((value) => value);

    return _azimuthValue;
  }
}
