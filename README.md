# Appcues Flutter Plugin

[![CircleCI](https://circleci.com/gh/appcues/appcues-flutter-plugin/tree/main.svg?style=shield&circle-token=16de1b3a77b1e448557552caa17a5c33ec38b679)](https://circleci.com/gh/appcues/appcues-flutter-plugin/tree/main)
[![Pub Version](https://img.shields.io/pub/v/appcues_flutter)](https://pub.dev/packages/appcues_flutter)
[![Pub Points](https://img.shields.io/pub/points/appcues_flutter)](https://pub.dev/packages/appcues_flutter/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/appcues/appcues-flutter-plugin/blob/main/LICENSE)

Appcues Flutter Plugin allows you to integrate Appcues experiences into your Flutter apps for iOS and Android devices.

This Plugin package is a bridge between the native Appcues SDKs in a Flutter application which sends user properties and events to the Appcues API and retrieves and renders Appcues content based on those properties and events.

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

### One Time Setup

#### Initializing the SDK

An instance of the Appcues SDK should be initialized when your app launches.

```dart
import 'package:appcues_flutter/appcues_flutter.dart';

Appcues.initialize('APPCUES_ACCOUNT_ID', 'APPCUES_APPLICATION_ID');
```

Initializing the SDK requires you to provide two values, an Appcues account ID, and an Appcues mobile application ID. These values can be obtained from your [Appcues settings](https://studio.appcues.com/settings/account). Refer to the help documentation on [Registering your mobile app in Studio](https://docs.appcues.com/article/848-registering-your-mobile-app-in-studio) for more information.

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
