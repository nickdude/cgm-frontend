import 'package:flutter/material.dart';

import '../models/data_page_model.dart';
import '../services/data_service.dart';
import '../utils/logger.dart';

class DataProvider extends ChangeNotifier {
  final DataService _dataService;

  DataProvider(this._dataService);

  DataPageModel? _dataPageModel;
  bool _isLoading = false;
  String? _error;

  DataPageModel? get dataPageModel => _dataPageModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDataPage(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _dataPageModel = await _dataService.getDataPageData(userId);
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Load data page error: $e');
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
