import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appcues_flutter/appcues_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('appcues_flutter');
  final List<MethodCall> log = <MethodCall>[];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'version') {
        return '42';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await Appcues.version(), '42');
  });

  test('setTheme invokes method channel with theme name', () async {
    await Appcues.setTheme(AppcuesTheme.dark);
    await Appcues.setTheme(AppcuesTheme.light);
    await Appcues.setTheme(AppcuesTheme.system);

    expect(log, <Matcher>[
      isMethodCall('setTheme', arguments: <String, Object?>{'theme': 'dark'}),
      isMethodCall('setTheme', arguments: <String, Object?>{'theme': 'light'}),
      isMethodCall('setTheme', arguments: <String, Object?>{'theme': 'system'}),
    ]);
  });

  test('initialize passes theme option when provided', () async {
    final options = AppcuesOptions()..theme = AppcuesTheme.dark;
    await Appcues.initialize('account-id', 'app-id', options);

    expect(log, hasLength(1));
    expect(log.first.method, 'initialize');
    final args = log.first.arguments as Map<Object?, Object?>;
    final nativeOptions = args['options'] as Map<Object?, Object?>;
    expect(nativeOptions['theme'], 'dark');
  });
}
