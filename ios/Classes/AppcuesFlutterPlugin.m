#import "AppcuesFlutterPlugin.h"
#if __has_include(<appcues_flutter/appcues_flutter-Swift.h>)
#import <appcues_flutter/appcues_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "appcues_flutter-Swift.h"
#endif

@implementation AppcuesFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppcuesFlutterPlugin registerWithRegistrar:registrar];
}
@end
