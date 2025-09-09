# Updating the Flutter example app to Swift Package Manager

```sh
$ flutter config --enable-swift-package-manager
$ flutter clean
$ flutter run
...
Adding Swift Package Manager integration...                      1,006ms
Running pod install...                                           1,510ms
```

There's now a `FlutterGeneratedPluginSwiftPackage` and the Appcues iOS SDK is installed via Swift Package Manager. However the notification service extension is still using CocoaPods. If you `flutter run` again, you'll see a notice: 

```
All plugins found for ios are Swift Packages, but your project still has
CocoaPods integration. Your project uses a non-standard Podfile and will need to
be migrated to Swift Package Manager manually. Some steps you may need to
complete include:
  * In the ios/ directory run "pod deintegrate"
  * Transition any Pod dependencies to Swift Package equivalents. See
  https://developer.apple.com/documentation/xcode/adding-package-dependencies-to
  -your-app
  * Transition any custom logic
  * Remove the include to "Pods/Target Support
  Files/Pods-Runner/Pods-Runner.debug.xcconfig" in your
  ios/Flutter/Debug.xcconfig
  * Remove the include to "Pods/Target Support
  Files/Pods-Runner/Pods-Runner.release.xcconfig" in your
  ios/Flutter/Release.xcconfig

Removing CocoaPods integration will improve the project's build time.
```

Let's fully remove the CocoaPods integration. We need to pay special attention to the notification service extension.

```sh
$ cd ios
$ pod deintegrate
$ rm Podfile Podfile.lock
# remove includes
$ sed -i '' '/Pods/d' Flutter/Debug.xcconfig
$ sed -i '' '/Pods/d' Flutter/Release.xcconfig
$ open Runner.xcworkspace
```

There's a number of things to do in Xcode:
1. If you're manually configuring push notifications, update references to `SwiftAppcuesFlutterPlugin` to `AppcuesFlutterPlugin`. (The compiler should automatically suggest this update)
2. Remove the reference to the deleted `Pods` xcodeproj
3. Remove the reference to the deleted `Pods` folder in `Runner`
4. Configure the notification service extension
   1. Select `Runner` in the sidebar and go to Project > Runner > Package Dependencies
   2. Add `appcues-ios-sdk` as a package dependency and add `AppcuesNotificationServiceExtension` to the notification service extension target. (No need to add AppcuesKit to the main app, since that's already managed)
   3. At this point a build should succeed, but you'll see a warning in the console:
      ```
      The CFBundleVersion of an app extension (null) must match that of its containing parent app ('4.3.7').
      ```
   4. Edit the notification service extension's `Info.plist` and set the `CFBundleVersion`:
        ```xml
      	<key>CFBundleVersion</key>
    	<string>$(FLUTTER_BUILD_NUMBER)</string>
        ```
   5. Associate the xcconfig files with the notification service extension so that `FLUTTER_BUILD_NUMBER` will be defined
   6. Select `Runner` in the sidebar and go to Project > Runner > Info > Configurations
   7. For each configuration, set the "Based on Configuration File" for the notification service extension to the xcconfig that matches `Runner`
5. Build and run the app 🎉

## Going back to Cocoapods

See https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-remove-swift-package-manager-integration

```sh
$ cd ios
# discard the changes we made above
$ git checkout .
$ flutter config --no-enable-swift-package-manager
$ flutter clean
```

# References

- https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors
- https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers