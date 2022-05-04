import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:appcues_flutter_sdk/appcues_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<bool> _initializeAppcues() async {
    await AppcuesFlutterSdk.initialize('ACCOUNT_ID', 'APP_ID');
    await AppcuesFlutterSdk.identify('flutter-user-00000');
    return true;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _initializeAppcues(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return MaterialApp(
          title: 'Appcues Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Appcues Flutter Demo'),
        );
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _sdkVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String sdkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      sdkVersion = await AppcuesFlutterSdk.version();
    } on PlatformException {
      sdkVersion = 'Failed to get sdk version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  void _triggerButtonEvent() async {
    await AppcuesFlutterSdk.track('flutter-event', {'from-flutter': true, 'prop1': 'value', 'prop2': 42});
  }

  void _showExperience() async {
    await AppcuesFlutterSdk.show('398313f7-824b-4058-82ae-75ce7a5911e4');
  }

  void _debug() async {
    await AppcuesFlutterSdk.debug();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('SDK version: $_sdkVersion\n'),
            ElevatedButton(
              style: style,
              onPressed: _triggerButtonEvent,
              child: const Text('Trigger Event'),
            ),
            ElevatedButton(
              style: style,
              onPressed: _showExperience,
              child: const Text('Show Experience'),
            ),
            ElevatedButton(
              style: style,
              onPressed: _debug,
              child: const Text('Debug'),
            ),
          ],
        ),
      ),
    );
  }
}