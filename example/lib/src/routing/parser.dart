import 'package:flutter/widgets.dart';

import '../routing.dart';
import 'route_definition.dart';

/// Parses the URI path into a [RouteDefinition].
class TemplateRouteParser extends RouteInformationParser<RouteDefinition> {
  final List<RouteDefinition> _routeDefinitions;
  final RouteDefinition initialRoute;

  RouteState? routeState;

  TemplateRouteParser(
    this.initialRoute, {
    /// The list of allowed routes
    required List<RouteDefinition> routeDefinitions,
  })  : _routeDefinitions = [
          ...routeDefinitions,
        ],
        assert(routeDefinitions
                .indexWhere((element) => element.path == initialRoute.path) !=
            -1);

  @override
  Future<RouteDefinition> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final path = routeInformation.location!;

    // by default, we stay on the current route from routeState, if nothing matches
    // if no current route, fall back to the initialRoute
    var parsedRoute = routeState?.route ?? initialRoute;

    for (var route in _routeDefinitions) {
      if (route.path == path) {
        parsedRoute = route;
      }
    }

    return parsedRoute;
  }

  @override
  RouteInformation restoreRouteInformation(RouteDefinition configuration) =>
      RouteInformation(location: configuration.path);
}
