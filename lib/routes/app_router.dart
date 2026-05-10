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
import '../screens/alarm/alarm_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/profile/setting_screen.dart';
import '../screens/profile/target_screen.dart';
import '../screens/profile/legal_detail_screen.dart';
import '../screens/quick_actions/diet_screen.dart';
import '../screens/quick_actions/insulin_screen.dart';
import '../screens/quick_actions/medicine_screen.dart';
import '../screens/quick_actions/exercise_screen.dart';
import '../screens/quick_actions/finger_blood_screen.dart';
import '../screens/devices/devices_list_screen.dart';

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
      builder: (context, state) {
        final epoch = int.tryParse(state.uri.queryParameters['actionEpoch'] ?? '');
        return DietScreen(initialEpochMs: epoch);
      },
    ),
    GoRoute(
      path: '/insulin',
      builder: (context, state) {
        final epoch = int.tryParse(state.uri.queryParameters['actionEpoch'] ?? '');
        return InsulinScreen(initialEpochMs: epoch);
      },
    ),
    GoRoute(
      path: '/medicine',
      builder: (context, state) {
        final epoch = int.tryParse(state.uri.queryParameters['actionEpoch'] ?? '');
        return MedicineScreen(initialEpochMs: epoch);
      },
    ),
    GoRoute(
      path: '/exercise',
      builder: (context, state) {
        final epoch = int.tryParse(state.uri.queryParameters['actionEpoch'] ?? '');
        return ExerciseScreen(initialEpochMs: epoch);
      },
    ),
    GoRoute(
      path: '/finger-blood',
      builder: (context, state) {
        final epoch = int.tryParse(state.uri.queryParameters['actionEpoch'] ?? '');
        return FingerBloodScreen(initialEpochMs: epoch);
      },
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) => const DevicesListScreen(),
    ),
    GoRoute(
      path: '/alarm',
      builder: (context, state) => const AlarmScreen(),
    ),
    GoRoute(
      path: '/target',
      builder: (context, state) => const TargetScreen(),
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/about/privacy-notice',
      builder: (context, state) => const LegalDetailScreen(
        title: 'Privacy Notice',
        bodyText: 'This is a placeholder privacy notice page. We will connect the final privacy policy content here later. For now, this screen exists so the About page links are functional and follow the same app styling.',
      ),
    ),
    GoRoute(
      path: '/about/terms-of-use',
      builder: (context, state) => const LegalDetailScreen(
        title: 'Terms of Use',
        bodyText: 'This is a placeholder terms of use page. The final legal copy will be added later. For now, the row is tappable and opens a dedicated page to match the requested navigation flow.',
      ),
    ),
  ],
);
