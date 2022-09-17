#import "FlutterAzimuthPlugin.h"
#if __has_include(<flutter_azimuth/flutter_azimuth-Swift.h>)
#import <flutter_azimuth/flutter_azimuth-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_azimuth-Swift.h"
#endif

@implementation FlutterAzimuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAzimuthPlugin registerWithRegistrar:registrar];
}
@end
