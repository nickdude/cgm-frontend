class AuthResponse {
  final String token;
  final String userId;
  final String message;
  final bool success;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.message,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}
