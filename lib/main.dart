import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/onboarding_service.dart';
import 'services/quick_action_service.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/quick_action_provider.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final profileService = ProfileService(apiService);
    final onboardingService = OnboardingService(apiService);
    final quickActionService = QuickActionService(apiService);

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthService>(create: (_) => authService),
        Provider<ProfileService>(create: (_) => profileService),
        Provider<OnboardingService>(create: (_) => onboardingService),
        Provider<QuickActionService>(create: (_) => quickActionService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, profileService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileService),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(onboardingService),
        ),
        ChangeNotifierProvider(
          create: (_) => QuickActionProvider(quickActionService),
        ),
      ],
      child: MaterialApp.router(
        title: 'CGM Health',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
        ),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}