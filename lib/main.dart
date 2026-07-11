import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// Config (flavors)
import 'config/app_flavor.dart';
import 'config/city_config.dart';

// Localización (i18n es/ca)
import 'l10n/app_localizations.dart';

// Services
import 'services/storage_service.dart';
import 'services/navigation_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/parkings_provider.dart';
import 'providers/reservations_provider.dart';

// Utils
import 'utils/constants.dart';
import 'utils/adaptive_theme.dart';
import 'utils/platform_performance.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/create_user_screen.dart';
import 'screens/login/delete_user_screen.dart';
import 'screens/login/change_password_screen.dart';
import 'screens/login/send_password_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/active_reservation_screen.dart';
import 'screens/main/help_screen.dart';
import 'screens/main/history_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/main/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.initialize();
  
  // Initialize platform-specific performance optimizations
  PlatformPerformance.initialize();
  
  // Apply initial system overlay
  AdaptiveTheme.applySystemOverlay();

  // Resolve the active city flavor (--dart-define=CITY=<slug>, default: demo).
  final cityConfig = resolveCityConfig();

  runApp(AparcabicisApp(cityConfig: cityConfig));
}

class AparcabicisApp extends StatelessWidget {
  /// Configuración de la ciudad activa (flavor). Si no se pasa, se resuelve
  /// desde `--dart-define=CITY=`.
  final CityConfig cityConfig;

  AparcabicisApp({super.key, CityConfig? cityConfig})
      : cityConfig = cityConfig ?? resolveCityConfig();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CityConfig>.value(value: cityConfig),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ParkingsProvider(seedParkings: cityConfig.seedParkings),
        ),
        ChangeNotifierProvider(create: (_) => ReservationsProvider()),
      ],
      child: Platform.isIOS ? _buildCupertinoApp() : _buildMaterialApp(),
    );
  }

  Widget _buildCupertinoApp() {
    return CupertinoApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      
      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Cupertino Theme
      theme: AdaptiveTheme.getCupertinoTheme(),
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.activeReservation: (context) => const ActiveReservationScreen(),
        AppRoutes.history: (context) => const HistoryScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.help: (context) => const HelpScreen(),
        AppRoutes.createUser: (context) => const CreateUserScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.deleteUser: (context) => const DeleteUserScreen(),
        AppRoutes.sendPassword: (context) => const SendPasswordScreen(),
      },
    );
  }

  Widget _buildMaterialApp() {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      
      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Material Theme
      theme: AdaptiveTheme.getMaterialTheme(),
      darkTheme: AdaptiveTheme.getMaterialTheme(isDark: true),
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.activeReservation: (context) => const ActiveReservationScreen(),
        AppRoutes.history: (context) => const HistoryScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.help: (context) => const HelpScreen(),
        AppRoutes.createUser: (context) => const CreateUserScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.deleteUser: (context) => const DeleteUserScreen(),
        AppRoutes.sendPassword: (context) => const SendPasswordScreen(),
      },
    );
  }
}
