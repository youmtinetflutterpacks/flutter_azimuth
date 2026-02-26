import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_azimuth_platform_interface.dart';

/// An implementation of [FlutterAzimuthPlatform] that uses method channels.
class MethodChannelFlutterAzimuth extends FlutterAzimuthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_azimuth');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
