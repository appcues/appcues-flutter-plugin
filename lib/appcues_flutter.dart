import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
  /// The default value is 1800 seconds (30 minutes).
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

  /// Applies to iOS only. When enabled, the iOS SDK will pass potential
  /// universal links back to the host application AppDelegate function
  /// `application(_:continue:restorationHandler:)`. The host
  /// application is responsible for returning true if the link was handled
  /// as a deep link into a screen in the app, or false if not. By default,
  /// universal link support is disabled for Flutter applications, since the
  /// default FlutterAppDelegate template always returns a true value from
  /// `application(_:continue:restorationHandler:)`and blocks subsequent link
  /// handling.
  bool? enableUniversalLinks;
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

/// A SemanticsTag that can be used to identify elements for targeting
/// Appcues content.
class AppcuesView extends SemanticsTag {
  /// The identifier used to locate a view element for targeting content.
  final String identifier;

  /// Initialize the AppcuesView with the given [identifier].
  const AppcuesView(this.identifier) : super(identifier);
}

/// This widget can be used to optionally host Appcues embedded experiences.
class AppcuesFrameView extends StatefulWidget {
  /// The frame identifier used to locate this view, if embedded content
  /// is eligible for rendering in this view.
  final String frameId;

  /// Initialize the AppcuesFrameView with the given [frameId]
  const AppcuesFrameView(this.frameId, {Key? key}) : super(key: key);

  @override
  _AppcuesFrameViewState createState() => _AppcuesFrameViewState();
}

class _AppcuesFrameViewState extends State<AppcuesFrameView> {
  // A non-zero size is needed to ensure that the native view
  // layoutSubviews is called at least once. Then, the intrinsic size of
  // the native view will control the SizedBox dimensions here to auto
  // size contents or set to zero if hidden.
  double _height = 0.1;
  double _width = 0.1;
  StreamSubscription? _sizeStream;

  @override
  Widget build(BuildContext context) {
    // construct the correct native view based on platform ios / android
    var nativeView = _nativeView(
        viewType: 'AppcuesFrameView',
        creationParams: {"frameId": widget.frameId},
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
          )
        },
        onPlatformViewCreated: (id) {
          _sizeStream = EventChannel("com.appcues.flutter/frame/$id")
              .receiveBroadcastStream()
              .listen((size) => setState(() {
                    _height = size['height'];
                    _width = size['width'];
                  }));
        });

    // use the SizedBox with the height update listener (above) to auto
    // size the content
    return SizedBox(height: _height, width: _width, child: nativeView);
  }

  Widget _nativeView(
      {required String viewType,
      required Map<String, dynamic> creationParams,
      required Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
      required PlatformViewCreatedCallback? onPlatformViewCreated}) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            gestureRecognizers: gestureRecognizers,
            onPlatformViewCreated: onPlatformViewCreated);
      case TargetPlatform.iOS:
        return UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            gestureRecognizers: gestureRecognizers,
            onPlatformViewCreated: onPlatformViewCreated);
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }

  @override
  void dispose() {
    // It is important that we stop listening to height updates from a
    // native view, if this widget is disposed - cancel the StreamSubscription.
    _sizeStream?.cancel();
    super.dispose();
  }
}

/// The main entry point of the Appcues plugin.
class Appcues {
  static List<SemanticsHandle> _semanticsHandles = [];

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
      "enableUniversalLinks": options?.enableUniversalLinks,
    };
    await _methodChannel.invokeMethod('initialize', {
      'accountId': accountId,
      'applicationId': applicationId,
      'options': nativeOptions,
      'additionalAutoProperties': <String, Object>{
        '_applicationFramework': 'flutter',
        '_dartVersion': Platform.version
      }
    });
  }

  static void enableElementTargeting() {
    // start with the rootPipelineOwner, passing into our listener function
    // will walk the nested tree of pipelineOwner objects and ensure we are
    // getting change updates from all.
    _listenToSemanticsUpdates(RendererBinding.instance.rootPipelineOwner);
  }

  static void disableElementTargeting() {
    for (var handle in _semanticsHandles) {
      handle.dispose();
    }
    _semanticsHandles.clear();
    _methodChannel.invokeMethod('setTargetElements', {'viewElements': []});
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
            Map<String, Object>.from(event["properties"])));
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
  static Future<void> anonymous() async {
    return await _methodChannel.invokeMethod('anonymous');
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
    return await _methodChannel
        .invokeMethod('show', {'experienceId': experienceId});
  }

  /// Verifies if an incoming [url] value is intended for the Appcues SDK.
  ///
  /// Returns `true` if the [url] matches the Appcues scheme or `false` if
  /// the [url] is not known by the Appcues SDK and should be handled by
  /// your application.  If the [url] is an Appcues URL, this function may
  /// launch an experience or otherwise alter the UI state.
  static Future<bool> didHandleURL(Uri url) async {
    return await _methodChannel
        .invokeMethod('didHandleURL', {'url': url.toString()});
  }

  static void _listenToSemanticsUpdates(PipelineOwner pipelineOwner) {
    var handle = pipelineOwner.ensureSemantics(
        listener: () => _semanticsChanged(pipelineOwner));
    _semanticsHandles.add(handle);
    // recurse over the children of this PipelineOwner to ensure we
    // set up listeners for each potential rendering tree
    pipelineOwner.visitChildren((child) => _listenToSemanticsUpdates(child));
  }

  // runs every time the SemanticsNode tree updates, capturing the known
  // layout information that can be used for Appcues element targeting
  static void _semanticsChanged(PipelineOwner pipelineOwner) {
    var rootSemanticNode = pipelineOwner.semanticsOwner?.rootSemanticsNode;

    List<Map<String, dynamic>> viewElements = [];

    if (rootSemanticNode != null) {
      // this function runs on each node in the tree, looking for
      // identifiable elements.
      bool visitor(SemanticsNode node) {
        // by default, we use the generated label, if non-empty
        var identifier = node.label;
        var tags = node.tags;

        // look through tags for a more specific AppcuesView identifier and
        // use that if possible.
        if (tags != null) {
          for (var tag in tags) {
            if (tag is AppcuesView) {
              identifier = tag.identifier;
            }
          }
        }

        if (identifier.isNotEmpty) {
          // the SemanticsNode rect is in local coordinates. This helper
          // will recursively walk the ancestors and transform the rect
          // into global coordinates for the screen.
          Rect transformToRoot(Rect rect, SemanticsNode? node) {
            var transform = node?.transform;
            var parent = node?.parent;
            if (transform == null) {
              if (parent != null) {
                return transformToRoot(rect, parent);
              } else {
                return rect;
              }
            }

            var transformed = rect;
            var offset = MatrixUtils.getAsTranslation(transform);
            if (offset != null) {
              transformed = rect.shift(offset);
            }

            return transformToRoot(transformed, node?.parent);
          }

          // do the transform to global coordinates
          var rect = transformToRoot(node.rect, node);

          // add this item to the set of captured views
          viewElements.add({
            'x': rect.left,
            'y': rect.top,
            'width': rect.width,
            'height': rect.height,
            'type': 'SemanticsNode',
            'identifier': identifier,
          });
        }

        // run the visitor on down through the tree
        node.visitChildren(visitor);
        return true;
      }

      // start the tree inspection
      rootSemanticNode.visitChildren(visitor);

      // pass the target elements found to the native side to capture
      // the current known set of views for element targeting
      _methodChannel
          .invokeMethod('setTargetElements', {'viewElements': viewElements});
    }
  }
}
