import 'package:flutter/material.dart';

import '../auth.dart';
import '../routing.dart';
import '../routing/route_definition.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class ExampleNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ExampleNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<ExampleNavigator> createState() => _ExampleNavigatorState();
}

class _ExampleNavigatorState extends State<ExampleNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ExampleAuthScope.of(context);

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        return route.didPop(result);
      },
      pages: [
        if (routeState.route.path == RouteDefinition.signin.path)
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) {
                authState.signIn(credentials.username);
                routeState.route = RouteDefinition.events;
              },
              onSkip: () async {
                routeState.route = RouteDefinition.events;
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const ExampleScaffold(),
          ),
        ],
      ],
    );
  }
}
