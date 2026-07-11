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
import 'services/biometric_service.dart';
import 'services/storage_service.dart';
import 'services/navigation_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/parkings_provider.dart';
import 'providers/reservations_provider.dart';
import 'providers/session_provider.dart';

// Repositorios (fase 1: implementaciones fake; la API real llega en fase 4)
import 'repositories/fake/fake_access_repository.dart';
import 'repositories/fake/fake_auth_repository.dart';
import 'repositories/fake/fake_backend.dart';
import 'repositories/fake/fake_config_repository.dart';
import 'repositories/fake/fake_parkings_repository.dart';
import 'repositories/fake/fake_reservations_repository.dart';

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
  const AparcabicisApp._({
    required this.cityConfig,
    required this.backend,
    this.biometricAuthenticator,
    super.key,
  });

  /// Construye la app para la ciudad del flavor (o la indicada, en tests).
  ///
  /// En fase 1 la app trabaja contra el backend simulado ([FakeBackend]); en
  /// fase 4 se sustituirán los `Fake*Repository` por los `Api*Repository`.
  factory AparcabicisApp({
    Key? key,
    CityConfig? cityConfig,
    FakeBackend? backend,
    BiometricAuthenticator? biometricAuthenticator,
  }) {
    final city = cityConfig ?? resolveCityConfig();
    return AparcabicisApp._(
      key: key,
      cityConfig: city,
      backend: backend ?? FakeBackend(seedParkings: city.seedParkings),
      biometricAuthenticator: biometricAuthenticator,
    );
  }

  /// Configuración de la ciudad activa (flavor).
  final CityConfig cityConfig;

  /// Backend simulado compartido por todos los repositorios fake.
  final FakeBackend backend;

  /// Biometría. En producción se resuelve sola (local_auth); en tests se
  /// inyecta una falsa, porque el emulador no tiene huella registrada.
  final BiometricAuthenticator? biometricAuthenticator;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CityConfig>.value(value: cityConfig),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: FakeAuthRepository(backend),
            biometricAuthenticator: biometricAuthenticator,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ParkingsProvider(
            parkingsRepository: FakeParkingsRepository(backend),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservationsProvider(
            reservationsRepository: FakeReservationsRepository(backend),
            accessRepository: FakeAccessRepository(backend),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(
            configRepository: FakeConfigRepository(backend),
          ),
        ),
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
