import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/profile_setup_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '+91 0000000000';
        return OtpVerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/profile/setup/phone-login',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        return ProfileSetupScreen(
          contactMode: ProfileContactMode.phoneLoginNeedsEmail,
          prefilledPhone: phone,
        );
      },
    ),
    GoRoute(
      path: '/profile/setup/email-login',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return ProfileSetupScreen(
          contactMode: ProfileContactMode.emailLoginNeedsPhone,
          prefilledEmail: email,
        );
      },
    ),
    // Add more routes as screens are created
    // GoRoute(
    //   path: '/signup',
    //   builder: (context, state) => const SignUpScreen(),
    // ),
    // GoRoute(
    //   path: '/dashboard',
    //   builder: (context, state) => const DashboardScreen(),
    // ),
  ],
);
