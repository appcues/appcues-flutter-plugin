import 'package:appcues_flutter/appcues_flutter.dart';
import 'package:flutter/material.dart';

import '../auth.dart';

class ProfileScreen extends StatefulWidget {
  final String title = 'Update Profile';

  final Function onSignOut;

  const ProfileScreen({required this.onSignOut, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ExampleAuthScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              widget.onSignOut();
            },
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.loose(const Size(600, 600)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Given Name'),
                controller: _givenNameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Family Name'),
                controller: _familyNameController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Semantics(
                tagForChildren: const AppcuesView("btnSaveProfile"),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(44),
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async {
                    if (!authState.isAnonymous) {
                      Appcues.identify(authState.username, {
                        "givenName": _givenNameController.value.text,
                        "familyName": _familyNameController.value.text,
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
