import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class OnboardingService {
  final ApiService _apiService;

  OnboardingService(this._apiService);

  String _extractApiMessage(Object error, String fallbackMessage) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        if (message is Map) {
          return message.values.map((value) => value.toString()).join(', ');
        }
      }

      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }

    return fallbackMessage;
  }

  Future<Map<String, dynamic>> getAnswers(String userId) async {
    try {
      final response = await _apiService.get('/onboarding/$userId');
      final payload = response.data is Map ? response.data['data'] : null;
      if (payload is! Map) {
        throw Exception('Invalid onboarding payload');
      }

      return Map<String, dynamic>.from(payload);
    } catch (e) {
      logger.e('Get onboarding answers error: $e');
      throw Exception(_extractApiMessage(e, 'Failed to load onboarding answers'));
    }
  }

  Future<Map<String, dynamic>> saveAnswers(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/onboarding/$userId', data: data);
      final payload = response.data is Map ? response.data['data'] : null;
      if (payload is! Map) {
        throw Exception('Invalid onboarding payload');
      }

      return Map<String, dynamic>.from(payload);
    } catch (e) {
      logger.e('Save onboarding answers error: $e');
      throw Exception(_extractApiMessage(e, 'Failed to save onboarding answers'));
    }
  }
}
