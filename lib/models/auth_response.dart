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
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final user = (data['user'] is Map<String, dynamic>)
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final tokens = (data['tokens'] is Map<String, dynamic>)
        ? data['tokens'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AuthResponse(
      token: (tokens['accessToken'] ?? json['token'] ?? '').toString(),
      userId: (user['id'] ?? user['_id'] ?? json['userId'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      success: json['success'] ?? false,
    );
  }
}
