import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/cgm_sdk_config.dart';
import '../services/cgm_connection_service.dart';
import '../utils/logger.dart';

class CgmConnectionProvider extends ChangeNotifier {
  CgmConnectionProvider(this._service) {
    _eventSub = _service.events.listen(_onSdkEvent, onError: (Object error) {
      _error = 'CGM event error: $error';
      notifyListeners();
    });
  }

  final CgmConnectionService _service;

  StreamSubscription<Map<String, dynamic>>? _eventSub;
  bool _isBusy = false;
  bool _isConnected = false;
  String? _error;
  String? _bindingStep;
  int? _syncProgress;
  Map<String, dynamic>? _deviceInfo;
  List<Map<String, dynamic>> _glucoseReadings = const [];
  List<Map<String, dynamic>> _historyReadings = const [];

  bool get isBusy => _isBusy;
  bool get isConnected => _isConnected;
  String? get error => _error;
  String? get bindingStep => _bindingStep;
  int? get syncProgress => _syncProgress;
  Map<String, dynamic>? get deviceInfo => _deviceInfo;
  List<Map<String, dynamic>> get glucoseReadings => _glucoseReadings;
  List<Map<String, dynamic>> get historyReadings => _historyReadings;

  Future<bool> connectWithSensorSn(String sensorSn) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _error = 'CGM SDK connection is supported on Android only.';
      notifyListeners();
      return false;
    }

    final normalizedSn = sensorSn.trim();
    if (normalizedSn.isEmpty) {
      _error = 'Sensor SN / code is required.';
      notifyListeners();
      return false;
    }

    if (!CgmSdkConfig.hasCredentials) {
      final missing = <String>[
        if (CgmSdkConfig.appId.isEmpty) 'CGM_SDK_APP_ID',
        if (CgmSdkConfig.appSecret.isEmpty) 'CGM_SDK_APP_SECRET',
      ].join(' and ');

      _error =
          'Missing CGM SDK credentials: $missing. Run with --dart-define=CGM_SDK_APP_ID=... and --dart-define=CGM_SDK_APP_SECRET=... (legacy aliases also accepted: CGM_SDK_APPID / CGM_SDK_APP_SECRECT).';
      notifyListeners();
      return false;
    }

    if (CgmSdkConfig.skipSdkAuth) {
      logger.w('CGM SDK auth is disabled via CGM_SDK_SKIP_AUTH=true');
    }

    _setBusy(true);
    _error = null;
    _bindingStep = null;
    _syncProgress = null;

    try {
      final hasPermissions = await _service.requestBlePermissions();
      if (!hasPermissions) {
        _error = 'Bluetooth/location permissions are required to connect the CGM sensor.';
        return false;
      }

      if (!CgmSdkConfig.skipSdkAuth) {
        final authorized = await _service.authorize(
          appId: CgmSdkConfig.appId,
          appSecret: CgmSdkConfig.appSecret,
        );

        if (!authorized) {
          _error = 'CGM SDK authorization failed.';
          return false;
        }
      }

      final connected = await _service.connect(normalizedSn);
      _isConnected = connected;
      if (!connected) {
        _error = 'Unable to connect to CGM sensor. Verify sensor SN and Bluetooth state.';
      }

      notifyListeners();
      return connected;
    } on PlatformException catch (e) {
      _error = e.message ?? e.code;
      logger.e('CGM platform exception: ${e.code} ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      logger.e('CGM connection failed: $e');
      notifyListeners();
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<List<Map<String, dynamic>>> loadHistoryFromIndexStart(
    String sensorSn, {
    int indexStart = 1,
  }) async {
    _setBusy(true);
    _error = null;
    try {
      final data = await _service.getHistoryFromIndexStart(
        sensorSn: sensorSn,
        indexStart: indexStart,
      );
      _historyReadings = data;
      notifyListeners();
      return data;
    } on PlatformException catch (e) {
      _error = e.message ?? e.code;
      notifyListeners();
      return const [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return const [];
    } finally {
      _setBusy(false);
    }
  }

  Future<List<Map<String, dynamic>>> loadHistoryFromTimeRange(
    String sensorSn, {
    required int startTimeSeconds,
    required int endTimeSeconds,
  }) async {
    _setBusy(true);
    _error = null;
    try {
      final data = await _service.getHistoryFromTimeRange(
        sensorSn: sensorSn,
        startTimeSeconds: startTimeSeconds,
        endTimeSeconds: endTimeSeconds,
      );
      _historyReadings = data;
      notifyListeners();
      return data;
    } on PlatformException catch (e) {
      _error = e.message ?? e.code;
      notifyListeners();
      return const [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return const [];
    } finally {
      _setBusy(false);
    }
  }

  Future<void> disconnect() async {
    _setBusy(true);
    _error = null;

    try {
      await _service.disconnect();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _error = 'Disconnect failed: $e';
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _onSdkEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString();
    if (type == 'connection') {
      final connected = event['connected'];
      if (connected is bool) {
        _isConnected = connected;
      }
      final error = event['error'];
      if (error is String && error.isNotEmpty) {
        _error = error;
      }
      notifyListeners();
      return;
    }

    if (type == 'device_info') {
      final payload = event['payload'];
      if (payload is Map) {
        _deviceInfo = Map<String, dynamic>.from(payload);
        notifyListeners();
      }
      return;
    }

    if (type == 'glucose_data') {
      final payload = event['payload'];
      if (payload is List) {
        _glucoseReadings = payload.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        notifyListeners();
      }
      return;
    }

    if (type == 'binding_step') {
      final step = event['step']?.toString();
      if (step != null && step.isNotEmpty) {
        _bindingStep = step;
        notifyListeners();
      }
      return;
    }

    if (type == 'sync_progress') {
      final progress = event['progress'];
      if (progress is int) {
        _syncProgress = progress;
        notifyListeners();
      } else if (progress is num) {
        _syncProgress = progress.toInt();
        notifyListeners();
      }
      return;
    }

    if (type == 'history_data') {
      final payload = event['payload'];
      if (payload is List) {
        _historyReadings = payload.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        notifyListeners();
      }
      return;
    }

    if (type == 'sdk_log') {
      final message = event['message']?.toString();
      if (message != null && message.isNotEmpty) {
        logger.i('CGM SDK: $message');
      }
      return;
    }

    if (type == 'device_error') {
      final error = event['error']?.toString();
      if (error != null && error.isNotEmpty) {
        _error = error;
        notifyListeners();
      }
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
