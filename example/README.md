# Appcues Flutter Example App

This is a simple Flutter application for iOS and Android that integrates with Appcues Flutter Plugin.

## 🚀 Setup

Refer to https://docs.flutter.dev/get-started/install for general Flutter setup.

```sh
# Install dependencies for the plugin. Only necessary because this is referenced locally by the example app.
flutter pub get

# Install dependencies for the example app.
cd ./example
flutter pub get
```

This example app requires you to fill in an Appcues Account ID and an Appcues Application ID in `lib/src/app.dart`. You can enter your own values found in [Appcues Studio](https://studio.appcues.com), or use the following test values:
```
APPCUES_ACCOUNT_ID=103523
APPCUES_APPLICATION_ID=d7aa03d2-330d-4a02-ab26-139b98ab261d
```

```sh
# Run the app on an open iOS simulator or Android emulator
flutter run
```

## ✨ Functionality

The example app demonstrates the core functionality of the Appcues Flutter plugin across 4 screens.

### Sign In Screen

This screen is identified as `Sign In` for screen targeting.

Provide a User ID for use with `Appcues.identify()` or select an anonymous ID using `Appcues.anonymous()`.

### Events Screen

This screen is identified as `Trigger Events` for screen targeting.

Two buttons demonstrate `Appcues.track()` calls.

The AppBar also includes a button to launch the in-app debugger with `Appcues.debug()`.

### Profile Screen

This screen is identified as `Update Profile` for screen targeting.

TextFields are included to update the profile attributes for the current user using `Appcues.identify()`.

The AppBar also includes a button to sign out and navigate back to the Sign In Screen along with calling `Appcues.reset()`.

### Group Screen

This screen is identified as `Update Group` for screen targeting.

A TextField is included to set the group for the current user using `Appcues.group()`.
