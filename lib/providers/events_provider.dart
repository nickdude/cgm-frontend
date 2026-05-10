import 'package:flutter/material.dart';

import '../models/data_page_model.dart';
import '../services/events_service.dart';
import '../utils/logger.dart';

class EventsProvider extends ChangeNotifier {
  final EventsService _eventsService;

  EventsProvider(this._eventsService);

  List<GlucoseEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  int _currentEventIndex = 0;

  List<GlucoseEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentEventIndex => _currentEventIndex;
  GlucoseEvent? get currentEvent => _events.isNotEmpty ? _events[_currentEventIndex] : null;

  Future<void> loadGlucoseEvents(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _events = await _eventsService.getGlucoseEvents(userId);
      _currentEventIndex = 0;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Load glucose events error: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void nextEvent() {
    if (_events.isNotEmpty) {
      _currentEventIndex = (_currentEventIndex + 1) % _events.length;
      notifyListeners();
    }
  }

  void previousEvent() {
    if (_events.isNotEmpty) {
      _currentEventIndex = (_currentEventIndex - 1 + _events.length) % _events.length;
      notifyListeners();
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
