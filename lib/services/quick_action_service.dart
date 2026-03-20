import 'package:dio/dio.dart';

import '../utils/logger.dart';
import 'api_service.dart';

class QuickActionService {
  final ApiService _apiService;

  QuickActionService(this._apiService);

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

  Future<void> _saveWithOptionalImages(
    String endpoint,
    Map<String, dynamic> payload,
    List<String> imagePaths,
    String fallbackMessage,
  ) async {
    try {
      if (imagePaths.isEmpty) {
        await _apiService.post(endpoint, data: payload);
        return;
      }

      final formDataMap = <String, dynamic>{
        ...payload,
      };

      final files = <MultipartFile>[];
      for (final path in imagePaths) {
        files.add(await MultipartFile.fromFile(path));
      }
      formDataMap['images'] = files;

      final formData = FormData.fromMap(formDataMap);
      await _apiService.post(endpoint, data: formData);
    } catch (e) {
      logger.e('$fallbackMessage error: $e');
      throw Exception(_extractApiMessage(e, fallbackMessage));
    }
  }

  Future<void> saveDiet(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    await _saveWithOptionalImages(
      '/quick-actions/$userId/diet',
      payload,
      imagePaths,
      'Failed to save diet',
    );
  }

  Future<void> saveInsulin(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    await _saveWithOptionalImages(
      '/quick-actions/$userId/insulin',
      payload,
      imagePaths,
      'Failed to save insulin',
    );
  }

  Future<void> saveMedicine(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    await _saveWithOptionalImages(
      '/quick-actions/$userId/medicine',
      payload,
      imagePaths,
      'Failed to save medicine',
    );
  }

  Future<void> saveExercise(
    String userId,
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    await _saveWithOptionalImages(
      '/quick-actions/$userId/exercise',
      payload,
      imagePaths,
      'Failed to save exercise',
    );
  }

  Future<void> saveFingerBlood(String userId, Map<String, dynamic> payload) async {
    try {
      await _apiService.post('/quick-actions/$userId/finger-blood', data: payload);
    } catch (e) {
      logger.e('Save finger blood error: $e');
      throw Exception(_extractApiMessage(e, 'Failed to save finger blood entry'));
    }
  }
}
