# Appcues Flutter Plugin

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/appcues/appcues-flutter-plugin/blob/main/LICENSE)

>NOTE: This is a pre-release project for testing as a part of our mobile beta program. If you are interested in learning more about our mobile product and testing it before it is officially released, please [visit our site](https://www.appcues.com/mobile) and request early access.
>
>If you have been contacted to be a part of our mobile beta program, we encourage you to try out this library and  provide feedback via Github issues and pull requests. Please note this library will not operate if you are not part of the mobile beta program.


Plugin package to bridge the native Appcues SDKs in a Flutter application.

- [Appcues Flutter Plugin](#appcues-flutter-plugin)
  - [🚀 Getting Started](#-getting-started)
    - [Installation](#installation)
    - [One Time Setup](#one-time-setup)
      - [Initializing the SDK](#initializing-the-sdk)
      - [Supporting Debugging and Experience Previewing](#supporting-debugging-and-experience-previewing)
    - [Identifying Users](#identifying-users)
    - [Tracking Screens and Events](#tracking-screens-and-events)
  - [🛠 Customization](#-customization)
  - [📝 Documentation](#-documentation)
  - [🎬 Examples](#-examples)
  - [👷 Contributing](#-contributing)
  - [📄 License](#-license)

## 🚀 Getting Started

### Prerequisites

**Android** - your application's `build.gradle` must have a `compileSdkVersion` of 32+ and `minSdkVersion` of 21+
```
android {
    compileSdkVersion 32    

    defaultConfig {
        minSdkVersion 21
    }
}
```

**iOS** - your application must target iOS 11+ to install the SDK, and iOS 13+ to render Appcues content. Update the iOS project xcodeproj to set the deployment target, if needed - typically in `iOS/Runner.xcodeproj`. In the application's `Podfile`, include at least this minimum version.
```rb
# Podfile
platform :ios, '11.0'
```

### Installation

1. Open the `pubspec.yaml` file located inside the app folder, and add `appcues_flutter:` under `dependencies`.
2. Install the dependency, using `flutter pub get` from the terminal.
3. **[⚠️ BETA ONLY]** Add the pod to your ios project's Podfile
    ```rb
    # needs to be explicitly included here until 1.0.0 is released to be able to find the prerelease versions.
    pod 'Appcues', '1.0.0-beta.4'
    ```

### One Time Setup

#### Initializing the SDK

An instance of the Appcues SDK should be initialized when your app launches.

```dart
import 'package:appcues_flutter/appcues_flutter.dart';

Appcues.initialize('APPCUES_ACCOUNT_ID', 'APPCUES_APPLICATION_ID');
```

Initializing the SDK requires you to provide two values, an Appcues account ID, and an Appcues mobile application ID. These values can be obtained from your [Appcues settings](https://studio.appcues.com/settings/account).

#### Supporting Debugging and Experience Previewing

Supporting debugging and experience previewing is not required for the Appcues Flutter Plugin to function, but it is necessary for the optimal Appcues builder experience. Refer to the [URL Scheme Configuration Guide](https://github.com/appcues/appcues-flutter-plugin/blob/main/doc/URLSchemeConfiguring.md) for details on how to configure.

### Identifying Users

In order to target content to the right users at the right time, you need to identify users and send Appcues data about them. A user is identified with a unique ID.

```dart
// Identify a user
Appcues.identify('my-user-id')
// Identify a user with property
Appcues.identify('my-user-id', {'Company': 'Appcues'})
```

### Tracking Screens and Events

Events are the “actions” your users take in your application, which can be anything from clicking a certain button to viewing a specific screen. Once you’ve installed and initialized the Appcues Flutter Plugin, you can start tracking screens and events using the following methods:

```dart
// Track event
Appcues.track('Sent Message')
// Track event with property
Appcues.track('Deleted Contact', {'ID': 123 })

// Track screen
Appcues.screen('Contact List')
// Track screen with property
Appcues.screen('Contact Details', {'Contact Reference': 'abc'})
```

## 📝 Documentation

Full documentation is available at https://docs.appcues.com/

## 🎬 Examples

The `example` directory in this repository contains full example iOS/Android app to providing references for correct installation and usage of the Appcues API.

## 👷 Contributing

See the [contributing guide](https://github.com/appcues/appcues-flutter-plugin/blob/main/CONTRIBUTING.md) to learn how to get set up for development and how to contribute to the project.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](https://github.com/appcues/appcues-flutter-plugin/blob/main/LICENSE) for more information.
