import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';

// Services
import 'services/storage_service.dart';
import 'services/navigation_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/stations_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.initialize();
  
  // Initialize platform-specific performance optimizations
  PlatformPerformance.initialize();
  
  // Apply initial system overlay
  AdaptiveTheme.applySystemOverlay();
  
  runApp(const AparcabicisApp());
}

class AparcabicisApp extends StatelessWidget {
  const AparcabicisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationsProvider()),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      
      // Cupertino Theme
      theme: AdaptiveTheme.getCupertinoTheme(),
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.activeReservation: (context) => const ActiveReservationScreen(),
        AppRoutes.history: (context) => const Placeholder(), // HistoryScreen
        AppRoutes.profile: (context) => const Placeholder(), // ProfileScreen
        AppRoutes.settings: (context) => const Placeholder(), // SettingsScreen
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      
      // Material Theme
      theme: AdaptiveTheme.getMaterialTheme(),
      darkTheme: AdaptiveTheme.getMaterialTheme(isDark: true),
      themeMode: ThemeMode.system,
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.activeReservation: (context) => const ActiveReservationScreen(),
        AppRoutes.history: (context) => const Placeholder(), // HistoryScreen
        AppRoutes.profile: (context) => const Placeholder(), // ProfileScreen
        AppRoutes.settings: (context) => const Placeholder(), // SettingsScreen
        AppRoutes.help: (context) => const HelpScreen(),
        AppRoutes.createUser: (context) => const CreateUserScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.deleteUser: (context) => const DeleteUserScreen(),
        AppRoutes.sendPassword: (context) => const SendPasswordScreen(),
      },
    );
  }
}
