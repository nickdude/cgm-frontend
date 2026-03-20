import 'package:flutter/material.dart';

import '../services/quick_action_service.dart';
import '../utils/logger.dart';

class QuickActionProvider extends ChangeNotifier {
  final QuickActionService _quickActionService;

  bool _isLoading = false;
  String? _error;

  QuickActionProvider(this._quickActionService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> saveDiet(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    return _runSave(() => _quickActionService.saveDiet(userId, payload, imagePaths));
  }

  Future<bool> saveInsulin(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    return _runSave(() => _quickActionService.saveInsulin(userId, payload, imagePaths));
  }

  Future<bool> saveMedicine(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    return _runSave(() => _quickActionService.saveMedicine(userId, payload, imagePaths));
  }

  Future<bool> saveExercise(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    return _runSave(() => _quickActionService.saveExercise(userId, payload, imagePaths));
  }

  Future<bool> saveFingerBlood(String userId, Map<String, dynamic> payload) async {
    return _runSave(() => _quickActionService.saveFingerBlood(userId, payload));
  }

  Future<bool> _runSave(Future<void> Function() action) async {
    _setLoading(true);
    _error = null;

    try {
      await action();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Quick action save error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is Exception) {
      final text = e.toString();
      const prefix = 'Exception: ';
      if (text.startsWith(prefix)) {
        return text.substring(prefix.length).trim();
      }
      return text;
    }

    return e.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
