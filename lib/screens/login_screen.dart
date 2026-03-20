import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;

  String _cleanPhoneForRoute(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String get _normalizedPhone {
    final onlyDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits;
  }

  Future<void> _goToOtpScreen() async {
    final phone = _normalizedPhone;
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid mobile number')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithPhone(phone);
    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent successfully')),
    );
    context.push('/otp?phone=%2B91%20$phone');
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final success = await authProvider.signInWithGoogle(
      'google_token_$timestamp',
      {
        'googleId': 'google_$timestamp',
        'email': 'google.user$timestamp@cgm.app',
        'name': 'Google User',
        'profileImage': null,
      },
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Google login failed')),
      );
      return;
    }

    final userEmail = authProvider.user?.email ?? '';
    context.push('/profile/setup/email-login?email=$userEmail');
  }

  Future<void> _handleAppleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final success = await authProvider.signInWithApple(
      'apple_token_$timestamp',
      {
        'appleId': 'apple_$timestamp',
        'email': 'apple.user$timestamp@privaterelay.appleid.com',
        'name': 'Apple User',
        'profileImage': null,
      },
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Apple login failed')),
      );
      return;
    }

    final userEmail = authProvider.user?.email ?? '';
    context.push('/profile/setup/email-login?email=$userEmail');
  }

  Future<void> _handleFacebookLogin() async {
    final authProvider = context.read<AuthProvider>();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final success = await authProvider.signInWithFacebook(
      'facebook_token_$timestamp',
      {
        'facebookId': 'facebook_$timestamp',
        'email': 'facebook.user$timestamp@cgm.app',
        'name': 'Facebook User',
        'profileImage': null,
      },
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Facebook login failed')),
      );
      return;
    }

    final userEmail = authProvider.user?.email ?? '';
    context.push('/profile/setup/email-login?email=$userEmail');
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.34).clamp(200.0, 280.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              SizedBox(
                height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/signin/signin.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE9EEF2),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.94),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 8,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1F2937),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                    const Text(
                      'Take control\nof your health',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56 / 2,
                        height: 1.08,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Elevate your health and wellness',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20 / 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 96,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDADDE1)),
                            color: AppColors.surface,
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🇮🇳', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2933),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Mobile Number',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16 / 2 * 2,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDADDE1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDADDE1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF111827),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enter your phone number. We will send you a\nconfirmation code there',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 / 2 * 2,
                        color: Color(0xFF8A8F98),
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _goToOtpScreen,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 20 / 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFD6D9DE)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.62),
                              fontSize: 16 / 2 * 2,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFD6D9DE)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialCircle(
                          icon: Icons.apple,
                          iconColor: Color(0xFF1F2933),
                          onTap: authProvider.isLoading ? null : _handleAppleLogin,
                        ),
                        SizedBox(width: 16),
                        _SocialCircle(
                          label: 'G',
                          iconColor: Color(0xFFEA4335),
                          onTap: authProvider.isLoading ? null : _handleGoogleLogin,
                        ),
                        SizedBox(width: 16),
                        _SocialCircle(
                          icon: Icons.facebook,
                          iconColor: Color(0xFF1877F2),
                          onTap: authProvider.isLoading ? null : _handleFacebookLogin,
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'By continuing, you agree to YoloMed app\'s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.78),
                        fontSize: 18 / 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFF0A6A68),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF0A6A68),
                              fontWeight: FontWeight.w700,
                              fontSize: 18 / 2,
                            ),
                          ),
                        ),
                        Text(
                          'and',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.78),
                            fontSize: 18 / 2,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFF0A6A68),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF0A6A68),
                              fontWeight: FontWeight.w700,
                              fontSize: 18 / 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  const _SocialCircle({
    this.icon,
    this.label,
    required this.iconColor,
    this.onTap,
  });

  final IconData? icon;
  final String? label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD6D9DE)),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: iconColor, size: 24)
            : Text(
                label ?? '',
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
      ),
    );
  }
}