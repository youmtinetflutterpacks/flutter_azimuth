import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_azimuth/flutter_azimuth_platform_interface.dart';
import 'package:flutter_azimuth/flutter_azimuth_method_channel.dart';

void main() {
  final FlutterAzimuthPlatform initialPlatform =
      FlutterAzimuthPlatform.instance;

  test('$MethodChannelFlutterAzimuth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAzimuth>());
  });
}
