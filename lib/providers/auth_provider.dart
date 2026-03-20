import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AuthProvider(this._authService, this._profileService);

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  
  String _extractErrorMessage(Object e) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        if (message is Map) {
          return message.values.map((value) => value.toString()).join(', ');
        }
      }
  
      if (e.message != null && e.message!.trim().isNotEmpty) {
        return e.message!;
      }
    }

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

  // Phone OTP Sign Up
  Future<bool> signUpWithPhone(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signUpWithPhone(phone);
      logger.i('OTP sent to $phone');
      return response['success'] ?? false;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Sign up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String phone, String otp) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.verifyOTP(phone, otp);
      if (authResponse.success) {
        _isLoggedIn = true;
        // Load user profile
        await _loadUserProfile(authResponse.userId);
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        return false;
      }
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Verify OTP error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle(
    String idToken,
    Map<String, dynamic> user,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithGoogle(idToken, user);
      if (authResponse.success) {
        _isLoggedIn = true;
        await _loadUserProfile(authResponse.userId);
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        return false;
      }
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Google sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Apple Sign In
  Future<bool> signInWithApple(
    String identityToken,
    Map<String, dynamic> user,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithApple(identityToken, user);
      if (authResponse.success) {
        _isLoggedIn = true;
        await _loadUserProfile(authResponse.userId);
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        return false;
      }
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Apple sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook(
    String accessToken,
    Map<String, dynamic> user,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithFacebook(accessToken, user);
      if (authResponse.success) {
        _isLoggedIn = true;
        await _loadUserProfile(authResponse.userId);
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        return false;
      }
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Facebook sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  Future<void> _loadUserProfile(String userId) async {
    try {
      _user = await _profileService.getProfile(userId);
    } catch (e) {
      logger.e('Load user profile error: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
