import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_azimuth_method_channel.dart';

abstract class FlutterAzimuthPlatform extends PlatformInterface {
  /// Constructs a FlutterAzimuthPlatform.
  FlutterAzimuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAzimuthPlatform _instance = MethodChannelFlutterAzimuth();

  /// The default instance of [FlutterAzimuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAzimuth].
  static FlutterAzimuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAzimuthPlatform] when
  /// they register themselves.
  static set instance(FlutterAzimuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
