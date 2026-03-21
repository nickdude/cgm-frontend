import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import '../utils/logger.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider(this._dashboardService);

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _dashboardData = await _dashboardService.getDashboardData(userId);
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Load dashboard error: $e');
      notifyListeners();
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
