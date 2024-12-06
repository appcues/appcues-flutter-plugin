import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:appcues_flutter/appcues_flutter.dart';
import 'package:flutter/material.dart';

import '../routing.dart';
import '../routing/route_definition.dart';
import 'scaffold_body.dart';

class ExampleScaffold extends StatelessWidget {
  const ExampleScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final selectedIndex = _getSelectedIndex(routeState.route);

    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: selectedIndex,
        body: const ExampleScaffoldBody(),
        onDestinationSelected: (idx) {
          if (idx == 0) routeState.route = RouteDefinition.events;
          if (idx == 1) routeState.route = RouteDefinition.profile;
          if (idx == 2) routeState.route = RouteDefinition.group;
          if (idx == 3) routeState.route = RouteDefinition.embeds;
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Events',
            icon: Icons.voicemail_outlined,
          ),
          AdaptiveScaffoldDestination(
            title: 'Profile',
            icon: Icons.person_outline,
          ),
          AdaptiveScaffoldDestination(
            title: 'Group',
            icon: Icons.people_outline,
          ),
          AdaptiveScaffoldDestination(
            title: 'Embeds',
            icon: Icons.ad_units_outlined,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: Semantics(
          tagForChildren: const AppcuesView("fab"),
          child: FloatingActionButton.extended(
            onPressed: () {
              Appcues.track("event3");
            },
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: const Text("FAB"),
            icon: const Icon(Icons.star),
          )
        )
      )
    );
  }

  int _getSelectedIndex(RouteDefinition route) {
    if (route == RouteDefinition.events) return 0;
    if (route == RouteDefinition.profile) return 1;
    if (route == RouteDefinition.group) return 2;
    if (route == RouteDefinition.embeds) return 3;
    return 0;
  }
}
