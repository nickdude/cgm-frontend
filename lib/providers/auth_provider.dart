import 'package:flutter/material.dart';
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

  // Phone OTP Sign Up
  Future<bool> signUpWithPhone(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _authService.signUpWithPhone(phone);
      logger.i('OTP sent to $phone');
      return response['success'] ?? false;
    } catch (e) {
      _error = e.toString();
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
      _error = e.toString();
      logger.e('Verify OTP error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email
  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.loginWithEmail(email, password);
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
      _error = e.toString();
      logger.e('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle(String idToken) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithGoogle(idToken);
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
      _error = e.toString();
      logger.e('Google sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Apple Sign In
  Future<bool> signInWithApple(String identityToken) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithApple(identityToken);
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
      _error = e.toString();
      logger.e('Apple sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook(String accessToken) async {
    _setLoading(true);
    _error = null;
    try {
      final authResponse = await _authService.signInWithFacebook(accessToken);
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
      _error = e.toString();
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
      _error = e.toString();
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
