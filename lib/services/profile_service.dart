import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService;
  static const bool _useMockApi = true;

  ProfileService(this._apiService);

  String _mockProfileKey(String userId) => 'mock_profile_$userId';

  Future<User> _buildDefaultMockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(AppConstants.userPhoneKey);

    return User(
      id: userId,
      email: '',
      phone: phone,
      fullName: '',
      photoUrl: null,
      signUpMethod: phone != null ? 'phone' : 'email',
      onboardingComplete: false,
      createdAt: DateTime.now(),
    );
  }

  // Get user profile from API
  Future<User> getProfile(String userId) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 400));
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_mockProfileKey(userId));

      if (stored != null) {
        final user = User.fromJson(jsonDecode(stored));
        await _saveProfileLocally(user);
        return user;
      }

      final user = await _buildDefaultMockUser(userId);
      await prefs.setString(_mockProfileKey(userId), jsonEncode(user.toJson()));
      await _saveProfileLocally(user);
      return user;
    }

    try {
      final response = await _apiService.get('/users/$userId');
      return User.fromJson(response.data['user']);
    } catch (e) {
      logger.e('Get profile error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<User> updateProfile(String userId, Map<String, dynamic> data) async {
    if (_useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      final prefs = await SharedPreferences.getInstance();
      final existing = await getProfile(userId);

      final user = User(
        id: existing.id,
        email: (data['email'] as String?) ?? existing.email,
        phone: (data['phone'] as String?) ?? existing.phone,
        fullName: (data['fullName'] as String?) ?? existing.fullName,
        photoUrl: (data['photoUrl'] as String?) ?? existing.photoUrl,
        signUpMethod: (data['signUpMethod'] as String?) ?? existing.signUpMethod,
        onboardingComplete:
            (data['onboardingComplete'] as bool?) ?? existing.onboardingComplete,
        createdAt: existing.createdAt,
      );

      await prefs.setString(_mockProfileKey(userId), jsonEncode(user.toJson()));
      await _saveProfileLocally(user);
      return user;
    }

    try {
      final response = await _apiService.put(
        '/users/$userId',
        data: data,
      );
      final user = User.fromJson(response.data['user']);
      await _saveProfileLocally(user);
      return user;
    } catch (e) {
      logger.e('Update profile error: $e');
      rethrow;
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      // Implementation for file upload will be done later
      logger.i('Uploading photo for user: $userId');
      return '';
    } catch (e) {
      logger.e('Upload photo error: $e');
      rethrow;
    }
  }

  // Save profile locally
  Future<void> _saveProfileLocally(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userProfileKey,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      logger.e('Save profile locally error: $e');
    }
  }

  // Get local profile
  Future<User?> getLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(AppConstants.userProfileKey);
      if (profileJson != null) {
        return User.fromJson(jsonDecode(profileJson));
      }
      return null;
    } catch (e) {
      logger.e('Get local profile error: $e');
      return null;
    }
  }
}
