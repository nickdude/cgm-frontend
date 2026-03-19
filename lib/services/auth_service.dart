import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/auth_response.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final _secureStorage = const FlutterSecureStorage();
  static const bool _useMockApi = true;
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
        '/auth/send-otp',
        data: {'phone': phone},
      );
      return response.data;
    } catch (e) {
      logger.e('Sign up with phone error: $e');
      rethrow;
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
        data: {'phone': phone, 'otp': otp},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
      }
      return authResponse;
    } catch (e) {
      logger.e('Verify OTP error: $e');
      rethrow;
    }
  }

  // Email Login
  Future<AuthResponse> loginWithEmail(String email, String password) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 650));
      final prefs = await SharedPreferences.getInstance();
      final mockUserId = 'mock_email_${email.toLowerCase()}';
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      await _saveToken(mockToken);
      await _saveUserId(mockUserId);
      await prefs.setBool(AppConstants.isLoggedInKey, true);

      return AuthResponse(
        token: mockToken,
        userId: mockUserId,
        message: 'Login successful',
        success: true,
      );
    }

    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
      }
      return authResponse;
    } catch (e) {
      logger.e('Login error: $e');
      rethrow;
    }
  }

  // Google Sign In
  Future<AuthResponse> signInWithGoogle(String idToken) async {
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
        '/auth/google-signin',
        data: {'idToken': idToken},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
      }
      return authResponse;
    } catch (e) {
      logger.e('Google sign in error: $e');
      rethrow;
    }
  }

  // Apple Sign In
  Future<AuthResponse> signInWithApple(String identityToken) async {
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
        '/auth/apple-signin',
        data: {'identityToken': identityToken},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
      }
      return authResponse;
    } catch (e) {
      logger.e('Apple sign in error: $e');
      rethrow;
    }
  }

  // Facebook Sign In
  Future<AuthResponse> signInWithFacebook(String accessToken) async {
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
        '/auth/facebook-signin',
        data: {'accessToken': accessToken},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success) {
        await _saveToken(authResponse.token);
        await _saveUserId(authResponse.userId);
      }
      return authResponse;
    } catch (e) {
      logger.e('Facebook sign in error: $e');
      rethrow;
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
