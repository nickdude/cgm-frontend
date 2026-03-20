import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';
import '../utils/logger.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _onboardingService;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _answers;
  bool _onboardingComplete = false;

  OnboardingProvider(this._onboardingService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get answers => _answers;
  bool get onboardingComplete => _onboardingComplete;

  Future<bool> loadAnswers(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _onboardingService.getAnswers(userId);
      _onboardingComplete = result['onboardingComplete'] == true;
      final answers = result['answers'];
      _answers = answers is Map ? Map<String, dynamic>.from(answers) : null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Load onboarding answers error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveAnswers(String userId, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _onboardingService.saveAnswers(userId, data);
      _onboardingComplete = result['onboardingComplete'] == true;
      final answers = result['answers'];
      _answers = answers is Map ? Map<String, dynamic>.from(answers) : null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Save onboarding answers error: $e');
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
