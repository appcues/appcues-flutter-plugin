import 'package:flutter/widgets.dart';

import 'route_definition.dart';
import 'parser.dart';

/// The current route state. To change the current route, call obtain the state
/// using `RouteStateScope.of(context)` and set the `route`:
///
/// ```
/// RouteStateScope.of(context).route = RouteDefinition.profile
/// ```
class RouteState extends ChangeNotifier {
  RouteDefinition _route;

  RouteState(TemplateRouteParser parser) : _route = parser.initialRoute;

  RouteDefinition get route => _route;

  set route(RouteDefinition route) {
    // Don't notify listeners if the path hasn't changed.
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }
}

/// Provides the current [RouteState] to descendant widgets in the tree.
class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static RouteState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RouteStateScope>()!.notifier!;
}
