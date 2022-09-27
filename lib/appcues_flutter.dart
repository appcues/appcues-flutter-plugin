import 'dart:async';
import 'package:flutter/services.dart';

/// A set of options that can be configured when initializing the Appcues
/// plugin.
class AppcuesOptions {
  /// Determines whether logging is enabled.
  bool? logging;

  /// The API host path to be used for Appcues requests.
  String? apiHost;

  /// The timeout value, in seconds, used to determine if a new session is
  /// started upon the application returning to the foreground.
  ///
  /// The default value is 1800 secondes (30 minutes).
  int? sessionTimeout;

  /// The number of analytics requests that can be stored on the local device
  /// and retried later, in the case of the device network connection being
  /// unavailable.
  ///
  /// Only the most recent requests, up to this count, are retained.
  /// The default and maximum value is 25.
  int? activityStorageMaxSize;

  /// The duration, in seconds, that an analytics request can be stored on
  /// the local device and retried later, in the case of the device network
  /// connection being unavailable.
  ///
  /// Only requests that are more recent than the max age will be retried. 
  /// There is no max age limitation if this value is left unset.
  int? activityStorageMaxAge;
}

/// Captures the details about analytics events that have been reported.
class AppcuesAnalytic {
  /// Indicates the type of the analytic.
  ///
  /// Value is one of: EVENT, SCREEN, IDENTIFY, or GROUP.
  String analytic;

  /// Contains the primary value of the analytic being tracked.
  ///
  /// For events - the event name, for screens - the screen title,
  /// for identify - the user ID, for group - the group ID.
  String value;

  /// Indicates if the analytic was internally generated by the SDK,
  /// as opposed to passed in from the host application.
  bool isInternal;

  /// Contains the properties that provide additional context about the
  /// analytic.
  Map<String, Object> properties;

  AppcuesAnalytic._internal(
      this.analytic, this.value, this.isInternal, this.properties);
}

/// The main entry point of the Appcues plugin.
class Appcues {
  static const MethodChannel _methodChannel = MethodChannel('appcues_flutter');
  static const EventChannel _analyticsChannel =
      EventChannel('appcues_analytics');

  /// Initialize the plugin.
  ///
  /// To initialize appcues, provide the [accountId] and [applicationId] for
  /// the application using the plugin.  Optionally, provide [options] to
  /// configure the plugin.
  static Future<void> initialize(String accountId, String applicationId,
      [AppcuesOptions? options]) async {
    // convert options to a Map to send to platform code
    Map<String, Object?> nativeOptions = <String, Object?>{
      "logging": options?.logging,
      "apiHost": options?.apiHost,
      "sessionTimeout": options?.sessionTimeout,
      "activityStorageMaxSize": options?.activityStorageMaxSize,
      "activityStorageMaxAge": options?.activityStorageMaxAge,
    };
    await _methodChannel.invokeMethod('initialize', {
      'accountId': accountId,
      'applicationId': applicationId,
      'options': nativeOptions
    });
  }

  static Stream<AppcuesAnalytic> get onAnalyticEvent {
    return _analyticsChannel.receiveBroadcastStream().map((event) =>
        // this repackages the platform level event from the channel
        // into a formatted object for the host application to
        // observe, via the Stream.
        AppcuesAnalytic._internal(
            event["analytic"],
            event["value"],
            event["isInternal"],
            Map<String, Object>.from(event["properties"])
        )
    );
  }

  /// Identify a user in the application.
  ///
  /// To identify a known user, pass the [userId] and optionally specify
  /// any additional custom [properties]
  static Future<void> identify(String userId,
      [Map<String, Object>? properties]) async {
    return await _methodChannel
        .invokeMethod('identify', {'userId': userId, 'properties': properties});
  }

  /// Identify a group for the current user.
  ///
  /// To specify that the current user belongs to a certain group, pass
  /// the [groupId] and optionally specify any additional custom group
  /// [properties] to update. A null value for [groupId] clears any previous
  /// group.
  static Future<void> group(String? groupId,
      [Map<String, Object>? properties]) async {
    return await _methodChannel
        .invokeMethod('group', {'groupId': groupId, 'properties': properties});
  }

  /// Track an event for an action taken by a user.
  ///
  /// Specify any [name] for the event and optionally any [properties] that
  /// supply more context about the event.
  static Future<void> track(String name,
      [Map<String, Object>? properties]) async {
    return await _methodChannel
        .invokeMethod('track', {'name': name, 'properties': properties});
  }

  /// Track a screen viewed by a user.
  ///
  /// Specify the [title] of the screen and optionally any [properties] that
  /// provide additional context about the screen view.
  static Future<void> screen(String title,
      [Map<String, Object>? properties]) async {
    return await _methodChannel
        .invokeMethod('screen', {'title': title, 'properties': properties});
  }

  /// Generate a unique ID for the current user when there is not a known
  /// identity to use in the [Appcues.identify] call.
  ///
  /// This will cause the plugin to begin tracking activity and checking for
  /// qualified content.
  static Future<void> anonymous([Map<String, Object>? properties]) async {
    return await _methodChannel.invokeMethod('anonymous', {'properties': properties});
  }

  /// Clear out the current user in this session.
  ///
  /// This can be used when the user logs out of your application.
  static Future<void> reset() async {
    return await _methodChannel.invokeMethod('reset');
  }

  /// Returns the current version of the Appcues SDK.
  static Future<String> version() async {
    return await _methodChannel.invokeMethod('version');
  }

  /// Launch the Appcues debugger over your app's UI.
  static Future<void> debug() async {
    return await _methodChannel.invokeMethod('debug');
  }

  /// Forces a specific Appcues experience to appear for the current user by
  /// passing in the [experienceId].
  ///
  /// If the experience was not able to be shown, and error is raised.
  /// This function ignores any targeting that is set on the experience.
  static Future<void> show(String experienceId) async {
    return await _methodChannel.invokeMethod('show', {'experienceId': experienceId});
  }

  /// Verifies if an incoming [url] value is intended for the Appcues SDK.
  ///
  /// Returns `true` if the [url] matches the Appcues scheme or `false` if
  /// the [url] is not known by the Appcues SDK and should be handled by
  /// your application.  If the [url] is an Appcues URL, this function may
  /// launch an experience or otherwise alter the UI state.
  static Future<bool> didHandleURL(Uri url) async {
    return await _methodChannel.invokeMethod('didHandleURL', {'url': url.toString()});
  }
}
