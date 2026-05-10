import 'package:dio/dio.dart';

import '../models/data_page_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class EventsService {
  final ApiService _apiService;

  EventsService(this._apiService);

  String _extractApiMessage(Object error, String fallbackMessage) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }

      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }

    return fallbackMessage;
  }

  Future<List<GlucoseEvent>> getGlucoseEvents(String userId) async {
    try {
      final response = await _apiService.get(
        '/events/$userId',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      final payload = response.data is Map ? response.data['data'] : null;
      if (payload is! List) {
        // Return mock events if API fails
        return _getMockGlucoseEvents();
      }

      return (payload as List)
          .whereType<Map>()
          .map((event) => GlucoseEvent.fromJson(Map<String, dynamic>.from(event)))
          .toList();
    } catch (e) {
      logger.e('Get glucose events error: $e');
      // Return mock events on any error
      return _getMockGlucoseEvents();
    }
  }

  List<GlucoseEvent> _getMockGlucoseEvents() {
    return [
      GlucoseEvent(
        id: '1',
        type: 'hyperglycemic',
        title: 'Hyperglycemic event detected',
        description: 'Hyperglycemic events are caused by a steep rise in glucose values while fasting or postprandial (after food consumption). Discover the causes of a glucose surge after eating and how to control it.',
        glucoseValue: 156,
        timestamp: '10:56 pm',
        detailedInfo: 'Your glucose (127) rose above the max target of (110 mg/dL).',
      ),
      GlucoseEvent(
        id: '2',
        type: 'improvement',
        title: '2- day improvement streak!',
        description: 'You\'ve made a great start! For the past two days, your metabolic score has been trending upward. Learn about the common myths regarding metabolic fitness to keep the pace going.',
        glucoseValue: 102,
        timestamp: 'Today',
        detailedInfo: null,
      ),
      GlucoseEvent(
        id: '3',
        type: 'hypoglycemic',
        title: 'Low glucose alert',
        description: 'Your glucose level has dropped below the minimum target. Make sure to have a quick snack.',
        glucoseValue: 65,
        timestamp: '3:30 pm',
        detailedInfo: 'Glucose reading: 65 mg/dL (below target of 70 mg/dL)',
      ),
    ];
  }
}
