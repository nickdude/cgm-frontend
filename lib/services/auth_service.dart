import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/auth_response.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final _secureStorage = const FlutterSecureStorage();
  static const bool _useMockApi = false;
  static const String _mockOtpValue = '123456';

  AuthService(this._apiService);

  String _normalizeIndianPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

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

  // Phone OTP Sign Up
  Future<Map<String, dynamic>> signUpWithPhone(String phone) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 650));
      final prefs = await SharedPreferences.getInstance();
      final normalizedPhone = _normalizeIndianPhone(phone);
      await prefs.setString('mock_last_phone', normalizedPhone);
      await prefs.setString('mock_last_otp', _mockOtpValue);

      logger.i('Mock OTP sent to $normalizedPhone -> $_mockOtpValue');
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': _mockOtpValue,
      };
    }

    try {
      final response = await _apiService.post(
        '/auth/request-otp',
        data: {'mobile': _normalizeIndianPhone(phone)},
      );
      return (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } catch (e) {
      logger.e('Sign up with phone error: $e');
      throw Exception(_extractApiMessage(e, 'Failed to request OTP'));
    }
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 650));
      final prefs = await SharedPreferences.getInstance();
      final lastPhone = prefs.getString('mock_last_phone') ?? '';
      final lastOtp = prefs.getString('mock_last_otp') ?? _mockOtpValue;
      final normalizedLastPhone = _normalizeIndianPhone(lastPhone);
      final normalizedPhone = _normalizeIndianPhone(phone);

      if (normalizedLastPhone != normalizedPhone || otp != lastOtp) {
        return AuthResponse(
          token: '',
          userId: '',
          message: 'Invalid OTP. Use $_mockOtpValue for now.',
          success: false,
        );
      }

      final mockUserId = 'mock_user_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      await _saveToken(mockToken);
      await _saveUserId(mockUserId);
      await prefs.setBool(AppConstants.isLoggedInKey, true);
      await prefs.setString(AppConstants.userPhoneKey, normalizedPhone);

      return AuthResponse(
        token: mockToken,
        userId: mockUserId,
        message: 'OTP verified successfully',
        success: true,
      );
    }

    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        data: {'mobile': _normalizeIndianPhone(phone), 'otp': otp},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isLoggedInKey, true);
        await prefs.setString(AppConstants.userPhoneKey, _normalizeIndianPhone(phone));
      }
      return authResponse;
    } catch (e) {
      logger.e('Verify OTP error: $e');
      throw Exception(_extractApiMessage(e, 'OTP verification failed'));
    }
  }

  // Google Sign In
  Future<AuthResponse> signInWithGoogle(
    String idToken,
    Map<String, dynamic> user,
  ) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      final userId = 'mock_google_user';
      final token = 'mock_google_token';
      await _saveToken(token);
      await _saveUserId(userId);
      return AuthResponse(
        token: token,
        userId: userId,
        message: 'Google sign-in successful',
        success: true,
      );
    }

    try {
      final response = await _apiService.post(
        '/auth/google',
        data: {
          'idToken': idToken,
          'user': user,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isLoggedInKey, true);
      }
      return authResponse;
    } catch (e) {
      logger.e('Google sign in error: $e');
      throw Exception(_extractApiMessage(e, 'Google login failed'));
    }
  }

  // Apple Sign In
  Future<AuthResponse> signInWithApple(
    String identityToken,
    Map<String, dynamic> user,
  ) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      final userId = 'mock_apple_user';
      final token = 'mock_apple_token';
      await _saveToken(token);
      await _saveUserId(userId);
      return AuthResponse(
        token: token,
        userId: userId,
        message: 'Apple sign-in successful',
        success: true,
      );
    }

    try {
      final response = await _apiService.post(
        '/auth/apple',
        data: {
          'identityToken': identityToken,
          'user': user,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isLoggedInKey, true);
      }
      return authResponse;
    } catch (e) {
      logger.e('Apple sign in error: $e');
      throw Exception(_extractApiMessage(e, 'Apple login failed'));
    }
  }

  // Facebook Sign In
  Future<AuthResponse> signInWithFacebook(
    String accessToken,
    Map<String, dynamic> user,
  ) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      final userId = 'mock_facebook_user';
      final token = 'mock_facebook_token';
      await _saveToken(token);
      await _saveUserId(userId);
      return AuthResponse(
        token: token,
        userId: userId,
        message: 'Facebook sign-in successful',
        success: true,
      );
    }

    try {
      final response = await _apiService.post(
        '/auth/facebook',
        data: {
          'accessToken': accessToken,
          'user': user,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.isLoggedInKey, true);
      }
      return authResponse;
    } catch (e) {
      logger.e('Facebook sign in error: $e');
      throw Exception(_extractApiMessage(e, 'Facebook login failed'));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      try {
        await _secureStorage.delete(key: AppConstants.userTokenKey);
        await _secureStorage.delete(key: AppConstants.userIdKey);
      } on PlatformException catch (e) {
        logger.w('Secure storage unavailable during logout: ${e.message}');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userTokenKey);
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.isLoggedInKey);
      await prefs.remove(AppConstants.userProfileKey);
    } catch (e) {
      logger.e('Logout error: $e');
    }
  }

  // Helper methods
  Future<void> _saveToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.userTokenKey, value: token);
    } on PlatformException catch (e) {
      logger.w('Secure storage unavailable for token, using prefs fallback: ${e.message}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userTokenKey, token);
    }
  }

  Future<void> _saveUserId(String userId) async {
    try {
      await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
    } on PlatformException catch (e) {
      logger.w('Secure storage unavailable for userId, using prefs fallback: ${e.message}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userIdKey, userId);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.userTokenKey);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userTokenKey);
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: AppConstants.userIdKey);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.userIdKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
