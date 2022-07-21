# Configuring the Appcues URL Scheme

The Appcues Flutter Plugin includes support for a custom URL scheme that enables previewing Appcues experiences in-app prior to publishing and launching the Appcues debugger.

## Prerequisites

Your application must be set up to handle incoming custom URL scheme links. There are several options available to configure and receive links in Flutter. One option is to use the package [uni_links](https://pub.dev/packages/uni_links). Alternatively, your application may have its own bridge to the native code to handle links.

Important: If your application is already using Flutter [Deep linking](https://docs.flutter.dev/development/ui/navigation/deep-linking) with the Router widget, you will need to disable the automatic link handling described in the documentation.

iOS - in Info.plist:
```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

Android - in AndroidManifest.xml for the main Activity:
```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="false" />
```

You will then be able to process all links and pass your application links through to the Router system. Refer to [Handle the Custom URL Scheme](#handle-the-custom-url-scheme) for more details.

## Register the Custom URL Scheme

Add the Appcues scheme to your project configuration. Replace `APPCUES_APPLICATION_ID` in the snippet below with your app's Appcues Application ID. For example, if your Appcues Application ID is `123-xyz` your url scheme value would be `appcues-123-xyz`.

iOS - in Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>appcues-APPCUES_APPLICATION_ID</string>
        </array>
    </dict>
</array>
```

Android - in AndroidManifest.xml for the main Activity:
```xml
<activity
    android:name="..."
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
    <intent-filter>
        <data android:scheme="appcues-APPCUES_APPLICATION_ID" />
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
    </intent-filter>
</activity>
```

## Handle the Custom URL Scheme

URLs need to be received and handled somewhere in your Flutter application. For example, if using [uni_links](https://pub.dev/packages/uni_links), you may have a listener  on `uriLinkStream`. When a new `Uri` is encountered, pass it along to the `AppcuesFlutter.didHandleURL` function. If the Appcues SDK recognized and processed the link, the return value is `true`.

If the link is not an Appcues custom scheme link, pass the link on to any other normal link handling code in your application. In this example, a Router widget is being used. The new link `.path` value is then sent to our `RouteInformationParser` implementation. The parsed route can then be used to update the `RouteState` in the application.

```dart
// Detect if a new deeplink was sent to the app
void _listenForDeeplinks() {
    _linkStreamSubscription = uriLinkStream.listen((Uri? uri) async {
        if (!mounted || uri == null) return;
        // Pass along to Appcues to potentially handle
        bool handled = await AppcuesFlutter.didHandleURL(uri);
        if (handled) return;

        // Otherwise, process the link as a normal app route
        var route = await _routeParser.parseRouteInformation(RouteInformation(location: uri.path));
        _routeState.route = route;
    });
}
```

For more detailed information about navigation and routing in Flutter, see the Flutter [navigation_and_routing](https://github.com/flutter/samples/tree/main/navigation_and_routing) example application.

## Verifying the Custom URL Scheme

Test that the URL scheme handling is set up correctly by opening the Appcues debugger:

```sh
# ios
xcrun simctl openurl booted "appcues-APPCUES_APPLICATION_ID://sdk/debugger"

# android
adb shell am start -a android.intent.action.VIEW -d "appcues-APPCUES_APPLICATION_ID://sdk/debugger"
```
