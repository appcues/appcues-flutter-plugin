import 'dart:async';

import 'package:appcues_flutter/appcues.dart';
import 'package:appcues_flutter_example/src/routing/route_definition.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final _auth = ExampleAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  bool _initialURILinkHandled = false;

  // handle for listening for incoming deeplinks
  StreamSubscription? _linkStreamSubscription;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed routes.
    _routeParser = TemplateRouteParser(RouteDefinition.signin,
      routeDefinitions: [
        RouteDefinition.signin,
        RouteDefinition.events,
        RouteDefinition.profile,
        RouteDefinition.group,
      ],
    );

    _routeState = RouteState(_routeParser);
    _routeParser.routeState = _routeState;

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => ExampleNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Initialize the Appcues Plugin
    _initializeAppcues();

    _handleInitialDeeplink();
    _listenForDeeplinks();

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    // Listen for screen changes to track in Appcues
    _routerDelegate.addListener(_handleRouteStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
    notifier: _routeState,
    child: ExampleAuthScope(
      notifier: _auth,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeParser,
        // Revert back to pre-Flutter-2.5 transition behavior:
        // https://github.com/flutter/flutter/issues/82053
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
      ),
    ),
  );

  Future<void> _initializeAppcues() async {
    AppcuesFlutterOptions options = AppcuesFlutterOptions();
    options.logging = true;
    await Appcues.initialize('APPCUES_ACCOUNT_ID', 'APPCUES_APPLICATION_ID', options);
  }

  // Detect if app was launched from a deeplink
  Future<void> _handleInitialDeeplink() async {
    // guard against processing initial link more than once
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;

      final initialURI = await getInitialUri();
      if (mounted && initialURI != null) {
        // Pass along to Appcues to potentially handle
        bool handled = await Appcues.didHandleURL(initialURI);
        if (handled) return;

        // Otherwise, process the link as a normal app route
        var route = await _routeParser.parseRouteInformation(RouteInformation(location: initialURI.path));
        _routeState.route = route;
      }
    }
  }

  // Detect if a new deeplink was sent to the app
  void _listenForDeeplinks() {
    _linkStreamSubscription = uriLinkStream.listen((Uri? uri) async {
      if (!mounted || uri == null) return;
      // Pass along to Appcues to potentially handle
      bool handled = await Appcues.didHandleURL(uri);
      if (handled) return;

      // Otherwise, process the link as a normal app route
      var route = await _routeParser.parseRouteInformation(RouteInformation(location: uri.path));
      _routeState.route = route;
    });
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      Appcues.reset();
    }
    else if (_auth.isAnonymous) {
      Appcues.anonymous();
    }
    else {
      Appcues.identify(_auth.username);
    }
  }

  void _handleRouteStateChanged() {
    Appcues.screen(_routerDelegate.currentConfiguration.title);
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routerDelegate.removeListener(_handleRouteStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    _linkStreamSubscription?.cancel();
    super.dispose();
  }
}
