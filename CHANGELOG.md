## 4.0.0-beta.1
* 🔧 Update release script to support 'release/*' branches (f0e7a6c)
* ⬆️ Update to SDK 4.0.0-beta.1 (1dc9a07)
* 🔧 Add google services key replacement in CI (0d75811)
* 🔧 Update build machines in CI config (14d7947)
* 🎬 Update notification service extension versions (8ef2ad6)
* 🔧 Configure example notification extension build (86bb8d6)
* 🎬 Update example app (eb00580)
* ⬆️ Update native iOS SDK dependency (2eb980c)
* ✨ sdk update 4.0.0-alpha1 on Android (60c733b)

## 3.3.0
* ⬆️ Update to SDK 3.3.0 (b9d2355)
* 📝 Update readme (a721165)

## 3.2.0
* 🔧 Sync up gradle compile/target to 34 (f491711)
* ⬆️ Update to SDK 3.2.0 (2f45e41)

## 3.1.10
* ⬆️ Update to iOS SDK 3.1.10 (1dc0609)

## 3.1.9
* ⬆️ Update to iOS SDK 3.1.9 (52003a1)
* 🚨 Fix lint warning (61080d0)
* 🐛 Fix issue with translating view coordinates from local to global (803da1f)
* 📝 Add doc for custom font configuring (6148c1d)
* 🎬 Add custom fonts (c421a12)
* 🐛 Fix Screen capture logic to account for custom views (68c35fb)

## 3.1.8
* ⬆️  Update sdk versions (4d267e3)
* 🐛 Fix Embeds on RTL (5102669)

## 3.1.7
* ⬆️ Update appcues sdk versions (dc4b6d8)

## 3.1.6
* ⬆️  Update sdk versions (60e0cbf)

## 3.1.5
* ⬆️  Update sdk versions (1fcf316)
* 📝 Add note about group call in readme and user identification docs (de1c0c1)
* 🔧 Update release script for publish (4779f93)

## 3.1.4
* ⬆️ Update appcues sdk versions (0b9fd6f)
* 📝 Update anchored tooltip doc with note about Flutter 3.16 update (4380f6d)
* 🚨 Fix deprecation warnings (c894696)
* 🔧 Update build configuration (87085a2)
* 🐛 Fix screen capture selector preview (11ba1ce)
* 🐛 Ensure FrameView margins are added to the content size to avoid unnecessary scrolling (fd79387)

## 3.1.3
* 📝 removing FlutterFragmentActivity requirement from README (cee2d14)
* ⬆️  Update appcues sdk versions (96f61a3)

## 3.1.2
* ⬆️  Update appcues sdk versions (0b04f78)

## 3.1.1
* ⬆️  Update Android SDK to v3.1.2 (37a7ddf)

## 3.1.0
* ⬆️ Update to 3.1.0 native SDKs (b121174)
* 📝 Fix doc link for embeds in README (db4b2f9)

## 3.0.0
* ⬆️ Update to Android SDK 3.0.2 (4ad11b6)
* ⬆️ Update to Android SDK 3.0.1 (ee8c1f9)
* ♻️ Update embed frame sizing to include height and width (b72fb3e)
* 🚨 Reformat dart file to pass lint checks (8bcc7b1)
* 📝 Add developer integration doc for embeds (22d4503)
* ♻️ Simplify iOS frame size calcuations (db638e5)
* 👌 Some code cleanup and simplification for embedded view handling (4a205e5)
* ✨ Add support for Android embed view hosting (a04f8bd)
* ✨ Add support for embed views on iOS (2018b72)
* ⬆️ Update to 3.0.0 native SDKs (8856f94)
* Bump activesupport from 6.1.7.3 to 7.0.7.2 in /example/ios (45da273)
* 📝 Update readme note to more strongly emphasize URL scheme configuration (8c45504)
* 🐛 Ensure no empty strings are present in selector property values (9f76db9)
* 🔧 Update Android example version substitution for test app distro (db07cd0)
* 👌 Update suggested items from latest package publish (385df35)

## 2.1.2
* 🚨 Remove unused import to fix dart pub score (e4d2937)
* 👌 Fix table spacing in doc (ebddb9e)
* 📝 Add anchored tooltip doc (689123e)
* ⬆️ Update Android SDK dependency to 2.1.4 (d4aba1c)
* 👌 Support turning Semantics tree observation on and off in the host application (fa0402c)
* 👌 Batch all discovered view elements in one array through the MethodChannel (d684dcf)
* 👌 Update selector property name to appcuesID (e717014)
* ✨ Add support for element targeting (921ece5)
* 📝 Update documentation to remove uni_links reference (140377f)
* ♻️ Replace usage of uni_links package with our own deep link handling (752be99)

## 2.1.1
* ⬆️  Update appcues sdk version to 2.1.2 (b53a949)

## 2.1.0
* ⬆️ Update Android SDK to 2.1.1 (eed6ed3)
* ⬆️ Update native SDK dependencies to 2.1 (8ef2ea4)
* 📝 Document our FlutterFragmentActivity requirement (3e630c5)
* 🔧 Include version update in release notes (af90b2c)

## 2.0.0
* 📝 Fix CircleCI shield in README (aec81f3)
* 🔧 Update release script to include version bump in release notes (275ce50)
* 💡 Fix a typo in comment (ccc0ea8)
* 💥 Remove properties parameter from anonymous function (a6d581b)
* ⬆️ Update native SDK dependencies to 2.0 (5e92c7f)
* 🔧 Update to Xcode 14.3 and Cocoapods 1.12.1 (1bffad5)
* 🔧 Update flutter orb to 2.0.1 (99d3929)
* 🔧 Use Xcode 14.2 to avoid cocoapod issue with 14.3 Also update Flutter to latest 3.7.11 (233d987)
* 🔧 Update CircleCI to use Xcode 14.3 (9529527)

## 1.4.0
* ⬆️ Update native dependencies for 1.4 (108fdee)
* 🔧 Add repo-specific whitesource/mend settings disable "Renovate" (automatic deps updates) (7bea52c)

## 1.3.0
* 🔧 Remove ⬆️ from commit filter on release notes (e8ecbbd)
* ⬆️ Update native SDK dependencies for 1.3 (db29cbe)
* Bump activesupport from 6.1.6.1 to 6.1.7.2 in /example/ios (9e5b8b6)
* 📝 Improve example snippets in README (6458b60)

## 1.2.0
* ⬆️ Update native SDK dependencies for 1.2 (e70c2bf)

## 1.1.1
* 🐛 Disable iOS Universal Link support by default, provide config option to enable (c2725a5)
* 🚨 Apply flutter formatting (8ac641d)

## 1.1.0
* ⬆️ Updates for SDK 1.1 (14d466e)

## 1.0.2
* 🔧 Update podspec version replacement in release script (80a203a)
* 🔧 Update formatting of podspec (6ebd371)
* 🔧 Fix android build.gradle version replacement in the release script (119213f)
* 🔧 Correct Android dependency version (cbaf07f)

## 1.0.1
* 👌 Code formatting clean up (e9ba90c)
* 👌 Improve error message (2a9dbe7)
* ✨ Add support for analytics observation with an EventChannel and Stream (202b76d)
* 🐛 Fix support for optional groupID, allow null to reset (412a0c0)

## 1.0.0


## 1.0.0-beta.2
* 👌 Fix copy paste bug in podspec (71ac8b2)
* 👌 Add a note about updating iOS min version in xcodeproj (81cc99f)
* 👌 Doc and API tweaks for beta usage (0804df5)

## 1.0.0-beta.1
Initial Beta release of the Appcues Flutter Plugin Package
* Plugin and example application usage
* Depends on iOS SDK version 1.0.0-beta.4
* Depends on Android SDK version 1.0.0-beta06
