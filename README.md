# Appcues Flutter Plugin

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/appcues/appcues-flutter-plugin/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/appcues/appcues-flutter-plugin/tree/main)
[![Pub Version](https://img.shields.io/pub/v/appcues_flutter)](https://pub.dev/packages/appcues_flutter)
[![Pub Points](https://img.shields.io/pub/points/appcues_flutter)](https://pub.dev/packages/appcues_flutter/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/appcues/appcues-flutter-plugin/blob/main/LICENSE)

Appcues Flutter Plugin allows you to integrate Appcues experiences into your Flutter apps for iOS and Android devices.

This Plugin package is a bridge between the native Appcues SDKs in a Flutter application which sends user properties and events to the Appcues API and retrieves and renders Appcues content based on those properties and events.

- [Appcues Flutter Plugin](#appcues-flutter-plugin)
  - [🚀 Getting Started](#-getting-started)
    - [Prerequisites](#prerequisites)
      - [Android](#android)
      - [iOS](#ios)
    - [Installation](#installation)
    - [One Time Setup](#one-time-setup)
      - [Initializing the SDK](#initializing-the-sdk)
      - [Supporting Builder Preview and Screen Capture](#supporting-builder-preview-and-screen-capture)
      - [Enabling Push Notifications](#enabling-push-notifications)
    - [Identifying Users](#identifying-users)
    - [Tracking Screens and Events](#tracking-screens-and-events)
    - [Anchored Tooltips](#anchored-tooltips)
    - [Embedded Experiences](#embedded-experiences)
  - [📝 Documentation](#-documentation)
  - [🎬 Examples](#-examples)
  - [👷 Contributing](#-contributing)
  - [📄 License](#-license)

## 🚀 Getting Started

### Prerequisites

#### Android
Your application's `build.gradle` must have a `compileSdkVersion` of 34+ and `minSdkVersion` of 21+, and use Android Gradle Plugin (AGP) 8+.
```
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
    }
}
```

Due to the SDK usage of Jetpack Compose, it is required to either:

1. apply `kotlin-android` plugin in app's build.gradle file.
	```
	plugins {  
	  id 'com.android.application' 
	  id 'kotlin-android' 
	}
	```
2. **OR** Update Android Gradle Plugin 8.4.0+

> [Related Google issue](https://issuetracker.google.com/issues/328687152) regarding usage of the Jetpack Compose dependency versions 1.6+

#### iOS
Your application must target iOS 11+ to install the SDK, and iOS 13+ to render Appcues content. Update the iOS project xcodeproj to set the deployment target, if needed - typically in `iOS/Runner.xcodeproj`. In the application's `Podfile`, include at least this minimum version.
```rb
# Podfile
platform :ios, '11.0'
```

### Installation

Add `appcues_flutter` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  appcues_flutter: <latest_version>
```

Then, install the dependency by running `flutter pub get` from the terminal.

### One Time Setup

#### Initializing the SDK

An instance of the Appcues SDK should be initialized when your app launches.

```dart
import 'package:appcues_flutter/appcues_flutter.dart';

Appcues.initialize('APPCUES_ACCOUNT_ID', 'APPCUES_APPLICATION_ID');
```

Initializing the SDK requires you to provide two values, an Appcues account ID, and an Appcues mobile application ID. These values can be obtained from your [Appcues settings](https://studio.appcues.com/settings/account). Refer to the help documentation on [Registering your mobile app in Studio](https://docs.appcues.com/article/848-registering-your-mobile-app-in-studio) for more information.

#### Supporting Builder Preview and Screen Capture

During installation, follow the steps outlined in [Configuring the Appcues URL Scheme](https://github.com/appcues/appcues-flutter-plugin/blob/main/doc/URLSchemeConfiguring.md). This is necessary for the complete Appcues builder experience, supporting experience preview, screen capture and debugging.

#### Enabling Push Notifications

In a Flutter app, push notifications are configured in the native projects for iOS and Android. Please refer to native documentation on [iOS](https://appcues.github.io/appcues-ios-sdk/documentation/appcueskit/pushnotifications/) and [Android](https://github.com/appcues/appcues-android-sdk/blob/main/docs/PushNotification.md) for more details. The `example` directory in this repository contains a reference implementation that includes push notification support.

### Identifying Users

In order to target content to the right users at the right time, you need to identify users and send Appcues data about them. A user is identified with a unique ID.

```dart
// Identify a user
Appcues.identify('my-user-id');
// Identify a user with property
Appcues.identify('my-user-id', {'Company': 'Appcues'});
```

After identifying a user, you can optionally associate that user with group.

```dart
// Associate a user with a group, optionally including group properties
Appcues.group('group-id', {'Plan Tier': 'standard'});
```

To ensure the most accurate content targeting based upon group information, it's recommended to supply the group information immediately after a new user is identified.

### Tracking Screens and Events

Events are the “actions” your users take in your application, which can be anything from clicking a certain button to viewing a specific screen. Once you’ve installed and initialized the Appcues Flutter Plugin, you can start tracking screens and events using the following methods:

```dart
// Track event
Appcues.track('Sent Message');
// Track event with property
Appcues.track('Deleted Contact', {'ID': 123 });

// Track screen
Appcues.screen('Contact List');
// Track screen with property
Appcues.screen('Contact Details', {'Contact Reference': 'abc'});
```

### Anchored Tooltips

Anchored tooltips use element targeting to point directly at specific views in your application. For more information about how to configure your application's views for element targeting, refer to the [Anchored Tooltips Guide](https://github.com/appcues/appcues-flutter-plugin/blob/main/doc/AnchoredTooltips.md).

### Embedded Experiences

Add `AppcuesFrameView` instances in your application layouts to support embedded experience content, with a non-modal presentation. For more information about how to configure your application layouts to use frame views, refer to the guide on [Configuring an AppcuesFrameView](https://github.com/appcues/appcues-flutter-plugin/blob/main/doc/AppcuesFrameViewConfiguring.md).

## 📝 Documentation

Full documentation is available at https://docs.appcues.com/

## 🎬 Examples

The `example` directory in this repository contains full example iOS/Android app to providing references for correct installation and usage of the Appcues API.

## 👷 Contributing

See the [contributing guide](https://github.com/appcues/appcues-flutter-plugin/blob/main/CONTRIBUTING.md) to learn how to get set up for development and how to contribute to the project.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](https://github.com/appcues/appcues-flutter-plugin/blob/main/LICENSE) for more information.
