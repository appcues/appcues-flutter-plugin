import 'package:appcues_flutter/appcues_flutter.dart';
import 'package:flutter/material.dart';

class GroupScreen extends StatefulWidget {
  final String title = 'Update Group';

  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _groupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                decoration: const InputDecoration(labelText: 'Group'),
                controller: _groupController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Foreground color
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  // Background color
                  primary: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size.fromHeight(44),
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () async {
                  var text = _groupController.value.text;
                  if (text.isNotEmpty) {
                    Appcues.group(text);
                  } else {
                    Appcues.group(null);
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
