import 'package:dio/dio.dart';

import '../models/dashboard_data.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

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

  Future<DashboardData> getDashboardData(String userId) async {
    try {
      final response = await _apiService.get(
        '/dashboard/$userId',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      final payload = response.data is Map ? response.data['data'] : null;
      if (payload is! Map) {
        throw Exception('Invalid dashboard payload');
      }

      return DashboardData.fromJson(Map<String, dynamic>.from(payload));
    } catch (e) {
      logger.e('Get dashboard data error: $e');
      throw Exception(_extractApiMessage(e, 'Failed to load dashboard data'));
    }
  }
}
