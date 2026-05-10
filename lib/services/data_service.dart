import 'package:dio/dio.dart';

import '../models/data_page_model.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class DataService {
  final ApiService _apiService;

  DataService(this._apiService);

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

  Future<DataPageModel> getDataPageData(String userId) async {
    try {
      final response = await _apiService.get(
        '/data/$userId',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      final payload = response.data is Map ? response.data['data'] : null;
      if (payload is! Map) {
        // Return mock data if API fails
        return _getMockDataPageModel();
      }

      return DataPageModel.fromJson(Map<String, dynamic>.from(payload));
    } catch (e) {
      logger.e('Get data page error: $e');
      // Return mock data on any error
      return _getMockDataPageModel();
    }
  }

  DataPageModel _getMockDataPageModel() {
    final now = DateTime.now();
    return DataPageModel(
      mock: true,
      generatedAt: now,
      currentGlucose: DailyGlucoseData(
        value: 102,
        unit: 'mg/dL',
        trend: '↑',
        timestamp: '10:02 am',
        hasAlert: false,
      ),
      metabolicScore: MetabolicScoreData(
        score: 81,
        description: 'Your Metabolic Score is in the',
        percentile: 'top 40% of all Users',
      ),
      calendar: CalendarData(
        year: now.year,
        month: now.month,
        days: _generateMockCalendarDays(now),
      ),
      stats: DailyStatsData(
        avgGlucose: 108,
        stdDev: 7,
        spikeTime: '1h 40m',
        spikeCount: 1,
      ),
    );
  }

  List<CalendarDay> _generateMockCalendarDays(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final firstDayOfWeek = DateTime(date.year, date.month, 1).weekday;
    
    final days = <CalendarDay>[];

    // Add empty days before month starts
    for (int i = 0; i < firstDayOfWeek - 1; i++) {
      days.add(CalendarDay(day: 0, glucose: null, status: 'empty'));
    }

    // Add days of month with mock glucose values
    final glucoseValues = [81, 71, 74, 60, 75, 84, 83, 81, 75, 70, 67, 68, 76, 58, 79, 82, 80, 77, 85, 88, 90, 92, 94, 96, 98, 100];
    
    for (int day = 1; day <= daysInMonth; day++) {
      final idx = (day - 1) % glucoseValues.length;
      final glucose = glucoseValues[idx];
      final status = _getGlucoseStatus(glucose);
      
      days.add(CalendarDay(
        day: day,
        glucose: glucose,
        status: status,
      ));
    }

    return days;
  }

  String _getGlucoseStatus(int glucose) {
    if (glucose >= 80 && glucose <= 130) return 'optimal';
    if (glucose > 130) return 'high';
    if (glucose < 80) return 'low';
    return 'empty';
  }
}
