// Aparcabicis Widget Tests
//
// Tests for the Aparcabicis bike parking reservation app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/main.dart';
import 'package:aparcabicis4/screens/splash_screen.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/providers/stations_provider.dart';
import 'package:aparcabicis4/providers/reservations_provider.dart';
import 'package:aparcabicis4/services/storage_service.dart';

void main() {
  // Initialize storage service for tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();
  });

  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AparcabicisApp());

    // Verify that the splash screen is shown
    expect(find.text('Aparcabicis'), findsOneWidget);
    expect(find.text('Inicializando...'), findsOneWidget);

    // Verify the bike icon is present
    expect(find.byType(Icon), findsWidgets);

    // Drain the 2s splash delay and let navigation complete so no timer leaks.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('Providers are properly initialized', (WidgetTester tester) async {
    // Build the app with providers
    await tester.pumpWidget(const AparcabicisApp());

    // The providers should be reachable from any descendant context.
    final BuildContext context = tester.element(find.byType(SplashScreen));
    expect(Provider.of<AuthProvider>(context, listen: false), isNotNull);
    expect(Provider.of<StationsProvider>(context, listen: false), isNotNull);
    expect(Provider.of<ReservationsProvider>(context, listen: false), isNotNull);

    // Drain the 2s splash delay and let navigation complete so no timer leaks.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Initial state is not logged in', () {
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.user, null);
    });

    test('Email validation works correctly', () {
      expect(authProvider.login('invalid-email', 'password123', false), 
             completion(false));
      expect(authProvider.login('test@example.com', 'short', false), 
             completion(false));
      expect(authProvider.login('test@example.com', 'password123', false), 
             completion(true));
    });
  });

  group('StationsProvider Tests', () {
    late StationsProvider stationsProvider;

    setUp(() {
      stationsProvider = StationsProvider();
    });

    test('Initial state has empty stations and favorites', () {
      expect(stationsProvider.stations, isEmpty);
      expect(stationsProvider.favoriteStations, isEmpty);
    });

    test('Initialize loads mock stations', () async {
      await stationsProvider.initialize();
      expect(stationsProvider.stations, isNotEmpty);
      expect(stationsProvider.stations.length, 8);
    });

    test('Toggle favorite works correctly', () async {
      await stationsProvider.initialize();
      final stationId = stationsProvider.stations.first.id;
      
      expect(stationsProvider.isFavorite(stationId), false);
      
      await stationsProvider.toggleFavorite(stationId);
      expect(stationsProvider.isFavorite(stationId), true);
      
      await stationsProvider.toggleFavorite(stationId);
      expect(stationsProvider.isFavorite(stationId), false);
    });
  });

  group('ReservationsProvider Tests', () {
    late ReservationsProvider reservationsProvider;

    setUp(() {
      reservationsProvider = ReservationsProvider();
    });

    test('Initial state has no active reservation', () {
      expect(reservationsProvider.hasActiveReservation, false);
      expect(reservationsProvider.activeReservation, null);
      expect(reservationsProvider.reservationHistory, isEmpty);
    });

    test('Format time works correctly', () {
      expect(reservationsProvider.formatTime(0), '0m 0s');
      expect(reservationsProvider.formatTime(60), '1m 0s');
      expect(reservationsProvider.formatTime(3661), '1h 1m 1s');
    });
  });
}
