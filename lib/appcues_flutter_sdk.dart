
import 'dart:async';

import 'package:flutter/services.dart';

class AppcuesFlutterSdk {
  static const MethodChannel _channel = MethodChannel('appcues_flutter_sdk');

  static Future<void> initialize(String accountId, String applicationId) async {
    return await _channel.invokeMethod('initialize', {'accountId': accountId, 'applicationId': applicationId});
  } 
  
  static Future<void> identify(String userId, [Map<String, Object>? properties = null]) async {
    return await _channel.invokeMethod('identify', {'userId': userId, 'properties': properties});
  }

  static Future<void> group(String groupId, [Map<String, Object>? properties = null]) async {
    return await _channel.invokeMethod('group', {'groupId': groupId, 'properties': properties});
  }

  static Future<void> track(String name, [Map<String, Object>? properties = null]) async {
    return await _channel.invokeMethod('track', {'name': name, 'properties': properties});
  } 

  static Future<void> screen(String title, [Map<String, Object>? properties = null]) async {
    return await _channel.invokeMethod('screen', {'title': title, 'properties': properties});
  } 

  static Future<void> anonymous([Map<String, Object>? properties = null]) async {
    return await _channel.invokeMethod('anonymous', {'properties': properties});
  }

  static Future<void> reset() async {
    return await _channel.invokeMethod('reset');
  }

  static Future<String> version() async {
    return await _channel.invokeMethod('version');
  }

  static Future<void> debug() async {
    return await _channel.invokeMethod('debug');
  }

  static Future<bool> show(String experienceId) async {
    return await _channel.invokeMethod('show', {'experienceId': experienceId});
  }
}
