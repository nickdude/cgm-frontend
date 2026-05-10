import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CgmConnectionService {
  static const MethodChannel _methodChannel = MethodChannel('com.belvix.app/cgm/methods');
  static const EventChannel _eventChannel = EventChannel('com.belvix.app/cgm/events');

  Stream<Map<String, dynamic>>? _events;

  bool get _isAndroidSupportedPlatform => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<Map<String, dynamic>> get events {
    if (!_isAndroidSupportedPlatform) {
      return const Stream<Map<String, dynamic>>.empty();
    }

    _events ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _events!;
  }

  Future<bool> requestBlePermissions() async {
    if (!_isAndroidSupportedPlatform) {
      return false;
    }

    final granted = await _methodChannel.invokeMethod<bool>('requestBlePermissions');
    return granted ?? false;
  }

  Future<bool> authorize({required String appId, required String appSecret}) async {
    if (!_isAndroidSupportedPlatform) {
      return false;
    }

    final authorized = await _methodChannel.invokeMethod<bool>(
      'authorize',
      <String, dynamic>{
        'appId': appId,
        'appSecret': appSecret,
      },
    );
    return authorized ?? false;
  }

  Future<bool> connect(String sensorSn) async {
    if (!_isAndroidSupportedPlatform) {
      return false;
    }

    final connected = await _methodChannel.invokeMethod<bool>(
      'connect',
      <String, dynamic>{'sensorSn': sensorSn},
    );
    return connected ?? false;
  }

  Future<bool> disconnect() async {
    if (!_isAndroidSupportedPlatform) {
      return false;
    }

    final disconnected = await _methodChannel.invokeMethod<bool>('disconnect');
    return disconnected ?? false;
  }

  Future<bool> isConnected() async {
    if (!_isAndroidSupportedPlatform) {
      return false;
    }

    final connected = await _methodChannel.invokeMethod<bool>('isConnected');
    return connected ?? false;
  }

  Future<List<Map<String, dynamic>>> getHistoryFromIndexStart({
    required String sensorSn,
    required int indexStart,
  }) async {
    if (!_isAndroidSupportedPlatform) {
      return const <Map<String, dynamic>>[];
    }

    final response = await _methodChannel.invokeMethod<List<dynamic>>(
      'getHistoryFromIndexStart',
      <String, dynamic>{
        'sensorSn': sensorSn,
        'indexStart': indexStart,
      },
    );

    return (response ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getHistoryFromTimeRange({
    required String sensorSn,
    required int startTimeSeconds,
    required int endTimeSeconds,
  }) async {
    if (!_isAndroidSupportedPlatform) {
      return const <Map<String, dynamic>>[];
    }

    final response = await _methodChannel.invokeMethod<List<dynamic>>(
      'getHistoryFromTimeRange',
      <String, dynamic>{
        'sensorSn': sensorSn,
        'startTimeSeconds': startTimeSeconds,
        'endTimeSeconds': endTimeSeconds,
      },
    );

    return (response ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
