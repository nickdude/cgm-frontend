import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../utils/logger.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._profileService);

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _extractErrorMessage(Object e) {
    if (e is DioException) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        final message = responseData['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
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

  // Load user profile
  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _profileService.getProfile(userId);
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Load profile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _profileService.updateProfile(userId, data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile photo
  Future<bool> uploadPhoto(String userId, String filePath) async {
    _setLoading(true);
    _error = null;
    try {
      final photoUrl = await _profileService.uploadProfilePhoto(userId, filePath);
      _user = _user?.copyWith(photoUrl: photoUrl);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      logger.e('Upload photo error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension UserCopyWith on User {
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? photoUrl,
    String? signUpMethod,
    bool? onboardingComplete,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      signUpMethod: signUpMethod ?? this.signUpMethod,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
