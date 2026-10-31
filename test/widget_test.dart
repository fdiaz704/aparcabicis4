// Aparcabicis Widget Tests
//
// Tests de la app contra los repositorios fake (fase 1).

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/main.dart';
import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/screens/splash_screen.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/providers/parkings_provider.dart';
import 'package:aparcabicis4/providers/reservations_provider.dart';
import 'package:aparcabicis4/providers/session_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_access_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_auth_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_parkings_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_reservations_repository.dart';
import 'package:aparcabicis4/services/storage_service.dart';

import 'support/version_check_doubles.dart';

/// Backend fake sin latencia, para que los tests no dependan de temporizadores.
FakeBackend newBackend() => FakeBackend(
      seedParkings: demoCity.seedParkings,
      latency: Duration.zero,
    );

/// La app con la comprobación de versión resuelta: si no, el splash se queda
/// esperando a package_info_plus, que en un test no contesta nunca.
Widget appUnderTest() {
  final backend = newBackend();
  return AparcabicisApp(
    cityConfig: demoCity,
    backend: backend,
    versionCheckService: upToDateVersionCheck(backend),
  );
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // Los tokens van a almacenamiento seguro: se mockea el canal nativo.
    FlutterSecureStorage.setMockInitialValues({});
    await StorageService.initialize();
  });

  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      appUnderTest(),
    );

    expect(find.text('Aparcabicis'), findsOneWidget);
    expect(find.text('Inicializando...'), findsOneWidget);
    expect(find.byType(Icon), findsWidgets);

    // Drenar el retardo de 2 s del splash y dejar que navegue.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('Providers are properly initialized', (WidgetTester tester) async {
    await tester.pumpWidget(
      appUnderTest(),
    );

    final BuildContext context = tester.element(find.byType(SplashScreen));
    expect(Provider.of<AuthProvider>(context, listen: false), isNotNull);
    expect(Provider.of<ParkingsProvider>(context, listen: false), isNotNull);
    expect(Provider.of<ReservationsProvider>(context, listen: false), isNotNull);
    expect(Provider.of<SessionProvider>(context, listen: false), isNotNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider(
        authRepository: FakeAuthRepository(newBackend()),
      );
    });

    test('el estado inicial no tiene sesión', () {
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.user, null);
    });

    test('valida el email y la longitud de la contraseña', () {
      expect(
        authProvider.login('invalid-email', 'password123', false),
        completion(false),
      );
      expect(
        authProvider.login('test@example.com', 'short', false),
        completion(false),
      );
      expect(
        authProvider.login('test@example.com', 'password123', false),
        completion(true),
      );
    });
  });

  group('ParkingsProvider', () {
    late ParkingsProvider parkingsProvider;

    setUp(() {
      parkingsProvider = ParkingsProvider(
        parkingsRepository: FakeParkingsRepository(newBackend()),
      );
    });

    test('el estado inicial no tiene aparcamientos ni favoritos', () {
      expect(parkingsProvider.parkings, isEmpty);
      expect(parkingsProvider.favoriteParkings, isEmpty);
    });

    test('initialize carga los aparcamientos del seed del flavor', () async {
      await parkingsProvider.initialize();
      expect(parkingsProvider.parkings, isNotEmpty);
      expect(parkingsProvider.parkings.length, demoCity.seedParkings.length);
    });

    test('alternar favorito funciona y persiste en el repositorio', () async {
      await parkingsProvider.initialize();
      final parkingId = parkingsProvider.parkings.first.id;

      expect(parkingsProvider.isFavorite(parkingId), false);

      await parkingsProvider.toggleFavorite(parkingId);
      expect(parkingsProvider.isFavorite(parkingId), true);

      await parkingsProvider.toggleFavorite(parkingId);
      expect(parkingsProvider.isFavorite(parkingId), false);
    });
  });

  group('ReservationsProvider', () {
    late ReservationsProvider reservationsProvider;

    setUp(() {
      final backend = newBackend();
      reservationsProvider = ReservationsProvider(
        reservationsRepository: FakeReservationsRepository(backend),
        accessRepository: FakeAccessRepository(backend),
      );
    });

    test('el estado inicial no tiene reserva activa', () {
      expect(reservationsProvider.hasActiveReservation, false);
      expect(reservationsProvider.activeReservation, null);
      expect(reservationsProvider.reservationHistory, isEmpty);
    });

    test('formatTime da el formato esperado', () {
      expect(reservationsProvider.formatTime(0), '0m 0s');
      expect(reservationsProvider.formatTime(60), '1m 0s');
      expect(reservationsProvider.formatTime(3661), '1h 1m 1s');
    });
  });
}
