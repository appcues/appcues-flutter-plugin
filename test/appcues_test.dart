import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appcues_flutter/appcues_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('appcues_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await Appcues.version(), '42');
  });
}
