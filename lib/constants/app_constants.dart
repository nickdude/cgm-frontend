class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userPhoneKey = 'user_phone';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // App Strings
  static const String appName = 'CGM Health';
  static const String appVersion = '1.0.0';
}
