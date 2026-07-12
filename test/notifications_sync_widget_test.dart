import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/l10n/app_localizations.dart';
import 'package:aparcabicis4/providers/reservations_provider.dart';
import 'package:aparcabicis4/providers/session_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_access_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_config_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_reservations_repository.dart';
import 'package:aparcabicis4/services/local_notifications_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/widgets/notifications_sync.dart';

/// Programador falso: anota lo que se programa y lo que se cancela.
class _FakeScheduler implements NotificationScheduler {
  final List<int> scheduled = [];
  int cancelPendingCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduled.add(id);
  }

  @override
  Future<void> cancelPending() async {
    cancelPendingCalls++;
    scheduled.clear();
  }
}

void main() {
  late _FakeScheduler scheduler;
  late FakeBackend backend;
  late ReservationsProvider reservations;

  final parking = demoCity.seedParkings.first;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();

    scheduler = _FakeScheduler();
    backend = FakeBackend(
      seedParkings: demoCity.seedParkings,
      latency: Duration.zero,
    );
    reservations = ReservationsProvider(
      reservationsRepository: FakeReservationsRepository(backend),
      accessRepository: FakeAccessRepository(backend),
    );
  });

  /// La app real cuelga NotificationsSync del árbol entero; aquí basta con los
  /// providers que consulta y las localizaciones (los textos de los avisos).
  Future<void> pumpSync(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: reservations),
          ChangeNotifierProvider(
            create: (_) => SessionProvider(
              configRepository: FakeConfigRepository(backend),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsSync(
            notifications: LocalNotificationsService(scheduler: scheduler),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('al reservar se programa la serie de avisos (RF-3.3)',
      (tester) async {
    await pumpSync(tester);
    expect(scheduler.scheduled, isEmpty, reason: 'sin reserva, nada que avisar');

    await tester.runAsync(() => reservations.createReservation(parking));
    await tester.pumpAndSettle();

    // Ventana de 30': avisos a T−10, T−5 y el vencimiento.
    expect(scheduler.scheduled, hasLength(3));
  });

  testWidgets('al hacer checkout se cancelan los avisos pendientes (RF-4.5)',
      (tester) async {
    await pumpSync(tester);

    await tester.runAsync(() => reservations.createReservation(parking));
    await tester.pumpAndSettle();
    await tester.runAsync(() => reservations.openDoor()); // check-in
    await tester.pumpAndSettle();
    expect(scheduler.scheduled, isNotEmpty, reason: 'en uso: avisos de uso');

    await tester.runAsync(() => reservations.finishUsage()); // checkout
    await tester.pumpAndSettle();

    // Sin reserva no queda ningún aviso vivo: el usuario ya recogió su bici.
    expect(reservations.hasActiveReservation, isFalse);
    expect(scheduler.scheduled, isEmpty);
    expect(scheduler.cancelPendingCalls, greaterThan(0));
  });

  testWidgets('un rebuild sin cambios no reprograma nada', (tester) async {
    await pumpSync(tester);

    await tester.runAsync(() => reservations.createReservation(parking));
    await tester.pumpAndSettle();
    final cancelsAfterReserving = scheduler.cancelPendingCalls;

    // Notificar sin tocar la reserva: la firma no cambia, no se reprograma.
    reservations.notifyListeners();
    await tester.pumpAndSettle();

    expect(scheduler.cancelPendingCalls, cancelsAfterReserving);
  });
}
