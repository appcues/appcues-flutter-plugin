import 'package:flutter/material.dart';

import '../auth.dart';
import '../routing.dart';
import '../routing/route_definition.dart';
import '../widgets/fade_transition_page.dart';
import 'events.dart';
import 'profile.dart';
import 'group.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [ExampleScaffold]
class ExampleScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const ExampleScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ExampleAuthScope.of(context);
    var currentRoute = routeState.route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.path == '/events')
          const FadeTransitionPage<void>(
            key: ValueKey('events'),
            child: EventsScreen(),
          )
        else if (currentRoute.path == '/profile')
          FadeTransitionPage<void>(
            key: const ValueKey('profile'),
            child: ProfileScreen(
              onSignOut: () {
                authState.signOut();
                routeState.route = RouteDefinition.signin;
              },
            ),
          )
        else if (currentRoute.path == '/group')
          const FadeTransitionPage<void>(
            key: ValueKey('group'),
            child: GroupScreen(),
          )

        // Avoid building a Navigator with an empty `pages` list when the
        // RouteState is set to an unexpected path, such as /signin.
        //
        // Since RouteStateScope is an InheritedNotifier, any change to the
        // route will result in a call to this build method, even though this
        // widget isn't built when those routes are active.
        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
