import 'package:flutter/material.dart';

class Credentials {
  final String username;

  Credentials(this.username);
}

class SignInScreen extends StatefulWidget {
  final String title = 'Sign In';
  final ValueChanged<Credentials> onSignIn;
  final Function onSkip;

  const SignInScreen({
    required this.onSignIn,
    required this.onSkip,
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController(text: "default-00000");

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.onSkip();
              },
              child: const Text('Skip', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'User ID'),
                controller: _usernameController,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Foreground color
                    onPrimary: Theme.of(context).colorScheme.onPrimary,
                    // Background color
                    primary: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(44),
                  ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async {
                    widget
                        .onSignIn(Credentials(_usernameController.value.text));
                  },
                  child: const Text('Sign In'),
                ),
              ),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    widget.onSignIn(Credentials(""));
                  },
                  child: const Text('Anonymous User')),
            ],
          ),
        ),
      );
}
