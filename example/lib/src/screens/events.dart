import 'package:appcues_flutter/appcues_flutter.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  final String title = 'Trigger Events';

  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Appcues.debug();
            },
            child: const Text('Debug'),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Semantics(
                  tagForChildren: const AppcuesView("btnEvent1"),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(44),
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () async {
                      Appcues.track("event1");
                    },
                    child: const Text('Trigger Event 1'),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Semantics(
                  tagForChildren: const AppcuesView("btnEvent2"),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(44),
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                    onPressed: () async {
                      Appcues.track("event2");
                    },
                    child: const Text('Trigger Event 2'),
                  )),
            ),
          ],
        ),
      ));
}
