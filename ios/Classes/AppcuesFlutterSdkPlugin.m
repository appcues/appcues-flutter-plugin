#import "AppcuesFlutterSdkPlugin.h"
#if __has_include(<appcues_flutter_sdk/appcues_flutter_sdk-Swift.h>)
#import <appcues_flutter_sdk/appcues_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "appcues_flutter_sdk-Swift.h"
#endif

@implementation AppcuesFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppcuesFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
