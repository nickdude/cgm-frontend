import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/onboarding_questions_screen.dart';
import '../screens/device_setup/device_setup_home_screen.dart';
import '../screens/device_setup/implant_sensor_step1_screen.dart';
import '../screens/device_setup/implant_sensor_step2_screen.dart';
import '../screens/device_setup/implant_sensor_step3_screen.dart';
import '../screens/device_setup/scan_qr_screen.dart';
import '../screens/device_setup/manual_code_entry_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/quick_actions/diet_screen.dart';
import '../screens/quick_actions/insulin_screen.dart';
import '../screens/quick_actions/medicine_screen.dart';
import '../screens/quick_actions/exercise_screen.dart';
import '../screens/quick_actions/finger_blood_screen.dart';

class AppRoutes {
  static const dashboard = 'dashboard';
}

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) {
    final path = state.uri.path;

    if (path == '/dashboard' || path == '/dashboard/') {
      return const DashboardScreen();
    }

    return Scaffold(
      body: Center(
        child: Text('Route not found: $path'),
      ),
    );
  },
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
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingQuestionsScreen(),
    ),
    GoRoute(
      path: '/device/setup',
      builder: (context, state) => const DeviceSetupHomeScreen(),
    ),
    GoRoute(
      path: '/device/implant/step-1',
      builder: (context, state) => const ImplantSensorStep1Screen(),
    ),
    GoRoute(
      path: '/device/implant/step-2',
      builder: (context, state) => const ImplantSensorStep2Screen(),
    ),
    GoRoute(
      path: '/device/implant/step-3',
      builder: (context, state) => const ImplantSensorStep3Screen(),
    ),
    GoRoute(
      path: '/device/scan-qr',
      builder: (context, state) => const ScanQrScreen(),
    ),
    GoRoute(
      path: '/device/manual-code',
      builder: (context, state) => const ManualCodeEntryScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/diet',
      builder: (context, state) => const DietScreen(),
    ),
    GoRoute(
      path: '/insulin',
      builder: (context, state) => const InsulinScreen(),
    ),
    GoRoute(
      path: '/medicine',
      builder: (context, state) => const MedicineScreen(),
    ),
    GoRoute(
      path: '/exercise',
      builder: (context, state) => const ExerciseScreen(),
    ),
    GoRoute(
      path: '/finger-blood',
      builder: (context, state) => const FingerBloodScreen(),
    ),
  ],
);
