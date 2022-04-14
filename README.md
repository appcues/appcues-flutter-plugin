# appcues-flutter-sdk
This project contains an Appcues Flutter plugin package.  See the [official Flutter documentation](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#plugin) for more information about plugin packages.  This plugin wraps the platform specific APIs for the Appcues iOS and Android SDKs in a way that can be easily integrated and used in a Flutter application.

## Getting Started
Download and install the Flutter SDK https://docs.flutter.dev/get-started/install/macos#get-sdk. Update PATH as noted in official documentation.

### Prerequisites
The Appcues Flutter plugin package references the underlying Android SDK from Maven (initially mavenLocal during dev), and the underlying iOS SDK from Cocoapods (initially [private podspec](https://github.com/appcues/cocoapods-specs) during dev).  You must have access to these libraries to be able to successfully build and run the plugin and the example application.

### Run the Example Application
The `example` directory has an example Flutter application that uses the Appcues plugin package.  The example can be run using either the Android Studio IDE, or via Terminal.

**To run in Android Studio**

Open the root `appcues-flutter-sdk` directory in Android Studio and run the Flutter application through the integrated tools in the IDE

More information: https://docs.flutter.dev/get-started/test-drive?tab=androidstudio

**To run via Terminal**

Launch and Android emulator or iOS simulator as the desired target to run the application.

```shell
> cd example
> flutter run
```

If multiple available devices are open, the command line tool will prompt to select which device to build and deploy the example.

More information: https://docs.flutter.dev/get-started/test-drive?tab=terminal