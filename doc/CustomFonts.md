# Registering Custom Fonts

This guide shows how to set up fonts in your Flutter project to work with the Appcues Flutter plugin.

The Appcues SDK loads fonts from the native app bundle using system APIs. This means the fonts must be configured in each of the Android and iOS projects for your app.

- [Registering Custom Fonts](#registering-custom-fonts)
  - [Naming Font Files](#naming-font-files)
  - [Android](#android)
    - [Maintaining a Single Source of Truth for Font Files](#maintaining-a-single-source-of-truth-for-font-files)
  - [iOS](#ios)
  - [Summary](#summary)

## Naming Font Files

The file name for a font must match the PostScript name of the font for your flows to properly load the custom font on both Android and iOS.
This is because in native Android apps, fonts are referenced by their resource name which is the filename[^1], while in native iOS apps, fonts are referenced by their PostScript name[^2].

On macOS, you can find the PostScript name of a font by opening it with the Font Book app and selecting the Font Info tab.

## Android

For an Android app, the font files need to be copied to the expected directory: `android/app/src/main/assets/fonts`.

### Maintaining a Single Source of Truth for Font Files

To maintain a single source of truth for your font files, it is recommended to *move* the font files from `fonts` to `android/app/src/main/assets/fonts` and then update `pubspec.yaml` with the new path:

```diff
  fonts:
  - family: Mulish
    fonts:
-      - asset: fonts/Mulish-Regular.ttf
-      - asset: fonts/Mulish-Bold.ttf
+      - asset: android/app/src/main/assets/fonts/Mulish-Regular.ttf
+      - asset: android/app/src/main/assets/fonts/Mulish-Bold.ttf
```

Alternatively you may copy the files to the expected android directory and not make changes to `pubspec.yaml`.

## iOS

For an iOS app, the font files need to be added to the Runner target in your Xcode project, and be added to `<UIAppFonts>` in `Info.plist`[^3].

1. Open the `Runner.xcodeproj` file in Xcode.
   1. File > Add Files to “Runner”.
   2. Navigate to `android/app/src/main/assets/fonts` in the file picker and select all font files.
   3. Ensure `Runner` is checked for the *Add to targets:* option.
   4. Click Add.

2. Open `ios/Runner/Info.plist` and add an array entry for `<UIAppFonts>` with a value for each font file name:
   ```
   <plist version="1.0">
   <dict>
       ...
       <key>UIAppFonts</key>
       <array>
           <string>Mulish-Regular.ttf</string>
           <string>Mulish-Bold.ttf</string>
       </array>
   </dict>
   ```

## Summary

Your project should look like this:

```
📁 android/app/src/main/assets
   📁 fonts
      📄 Mulish-Bold.ttf    // File name matches PostScript name
      📄 Mulish-Regular.ttf // File name matches PostScript name
📁 fonts                    // Now empty because files have moved to android project      
📁 ios
   📁 Runner
      📄 Info.plist         // <UIAppFonts> added
      📄 Runner.xcodeproj   // References to font files added
📄 pubspec.yaml             // Updated with font paths pointing to the android project
```

Build and run your app with these changes. You can use the Available Fonts section of the Appcues Debugger in a new build to verify that fonts are properly installed. If successful, your custom fonts will show in the App-Specific Fonts section of the Available Fonts detail screen.

[^1]: "The resource name, which is either the filename excluding the extension..." https://developer.android.com/guide/topics/resources/providing-resources
[^2]: "When retrieving the font with `custom(_:size:)`, match the name of the font with the font’s PostScript name." https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text/#Apply-a-font-supporting-dynamic-sizing
[^3]: Refer to https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app

