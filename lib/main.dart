import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/onboarding_service.dart';
import 'services/quick_action_service.dart';
import 'services/dashboard_service.dart';
import 'services/data_service.dart';
import 'services/events_service.dart';
import 'services/cgm_connection_service.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/quick_action_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/data_provider.dart';
import 'providers/events_provider.dart';
import 'providers/device_provider.dart';
import 'providers/cgm_connection_provider.dart';
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
    final dashboardService = DashboardService(apiService);
    final dataService = DataService(apiService);
    final eventsService = EventsService(apiService);
    final cgmConnectionService = CgmConnectionService();

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthService>(create: (_) => authService),
        Provider<ProfileService>(create: (_) => profileService),
        Provider<OnboardingService>(create: (_) => onboardingService),
        Provider<QuickActionService>(create: (_) => quickActionService),
        Provider<DashboardService>(create: (_) => dashboardService),
        Provider<DataService>(create: (_) => dataService),
        Provider<EventsService>(create: (_) => eventsService),
        Provider<CgmConnectionService>(create: (_) => cgmConnectionService),
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
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardService),
        ),
        ChangeNotifierProvider(
          create: (_) => DataProvider(dataService),
        ),
        ChangeNotifierProvider(
          create: (_) => EventsProvider(eventsService),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CgmConnectionProvider(cgmConnectionService),
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