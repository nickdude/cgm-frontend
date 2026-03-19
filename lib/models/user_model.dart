class User {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? photoUrl;
  final String? signUpMethod; // 'phone', 'google', 'apple', 'facebook'
  final bool onboardingComplete;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    this.photoUrl,
    this.signUpMethod,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      fullName: json['fullName'] ?? '',
      photoUrl: json['photoUrl'],
      signUpMethod: json['signUpMethod'],
      onboardingComplete: json['onboardingComplete'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'signUpMethod': signUpMethod,
      'onboardingComplete': onboardingComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
