import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/models/app_params.dart';
import 'package:aparcabicis4/models/parking.dart';
import 'package:aparcabicis4/models/reservation.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/repository_exception.dart';
import 'package:aparcabicis4/services/storage_service.dart';

const _parkings = <Parking>[
  Parking(
    id: 'p1',
    name: 'Uno',
    address: 'Calle Uno',
    availableSpots: 2,
    totalSpots: 5,
    lat: 0,
    lng: 0,
  ),
  Parking(
    id: 'lleno',
    name: 'Lleno',
    address: 'Calle Llena',
    availableSpots: 0,
    totalSpots: 4,
    lat: 0,
    lng: 0,
  ),
];

void main() {
  /// Reloj controlable: permite probar el vencimiento sin esperar 30 minutos.
  late DateTime now;
  late FakeBackend backend;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();

    now = DateTime(2026, 7, 12, 10);
    backend = FakeBackend(
      seedParkings: _parkings,
      latency: Duration.zero,
      clock: () => now,
    );
    await backend.load();
  });

  group('parámetros del sistema (spec)', () {
    test('son los acordados: ventana 30\', uso 840\', avisos {10,5}/{30,15,5}/30\'',
        () {
      expect(backend.params.reservationWindowMin, 30);
      expect(backend.params.maxUseMin, 840);
      expect(backend.params.reservationWarningsMin, [10, 5]);
      expect(backend.params.useWarningsMin, [30, 15, 5]);
      expect(backend.params.overstayIntervalMin, 30);
      expect(backend.params, AppParams.defaults);
    });
  });

  group('crear reserva', () {
    test('crea una reserva pending que vence a los 30 minutos y ocupa plaza',
        () async {
      final reservation = await backend.createReservation('p1');

      expect(reservation.status, ReservationStatus.pending);
      expect(reservation.createdAt, now);
      expect(reservation.expiresAt, now.add(const Duration(minutes: 30)));
      expect(reservation.checkinAt, isNull);
      expect(reservation.maxUntil, isNull);

      // La ocupación la deriva el backend.
      expect(backend.findParking('p1')!.availableSpots, 1);
    });

    test('una segunda reserva da RESERVATION_CONFLICT (RF-3.2)', () async {
      await backend.createReservation('p1');

      expect(
        () => backend.createReservation('p1'),
        throwsA(isA<RepositoryException>().having(
          (e) => e.code,
          'code',
          RepositoryErrorCodes.reservationConflict,
        )),
      );
    });

    test('sin plazas libres da PARKING_FULL', () async {
      expect(
        () => backend.createReservation('lleno'),
        throwsA(isA<RepositoryException>().having(
          (e) => e.code,
          'code',
          RepositoryErrorCodes.parkingFull,
        )),
      );
    });
  });

  group('máquina de estados (specs/03)', () {
    test('open sobre pending hace check-in: pending → active y fija maxUntil',
        () async {
      final reservation = await backend.createReservation('p1');

      now = now.add(const Duration(minutes: 5));
      final active = await backend.openDoor(reservation.id);

      expect(active.status, ReservationStatus.active);
      expect(active.checkinAt, now);
      // maxUntil = checkin + uso máximo (840 min).
      expect(active.maxUntil, now.add(const Duration(minutes: 840)));
    });

    test('abrir de nuevo durante active no cambia el estado ni el check-in',
        () async {
      final reservation = await backend.createReservation('p1');
      final active = await backend.openDoor(reservation.id);

      now = now.add(const Duration(hours: 2));
      final again = await backend.openDoor(reservation.id);

      expect(again.status, ReservationStatus.active);
      expect(again.checkinAt, active.checkinAt);
      expect(again.maxUntil, active.maxUntil);
    });

    test('checkout desde active → completed, libera plaza y va al historial',
        () async {
      final reservation = await backend.createReservation('p1');
      await backend.openDoor(reservation.id);

      now = now.add(const Duration(hours: 3));
      final completed = await backend.checkout(reservation.id);

      expect(completed.status, ReservationStatus.completed);
      expect(completed.checkoutAt, now);
      expect(completed.durationMinutes, 180);

      expect(await backend.fetchCurrentReservation(), isNull);
      expect(backend.history.first.status, ReservationStatus.completed);
      // La plaza vuelve a estar libre.
      expect(backend.findParking('p1')!.availableSpots, 2);
    });

    test('cancelar desde pending → cancelled y libera la plaza (RF-3.5)',
        () async {
      final reservation = await backend.createReservation('p1');
      final cancelled = await backend.cancelReservation(reservation.id);

      expect(cancelled.status, ReservationStatus.cancelled);
      expect(await backend.fetchCurrentReservation(), isNull);
      expect(backend.findParking('p1')!.availableSpots, 2);
    });

    test('no se puede cancelar una reserva ya activa', () async {
      final reservation = await backend.createReservation('p1');
      await backend.openDoor(reservation.id);

      expect(
        () => backend.cancelReservation(reservation.id),
        throwsA(isA<RepositoryException>().having(
          (e) => e.code,
          'code',
          RepositoryErrorCodes.reservationInvalidState,
        )),
      );
    });

    test('no se puede hacer checkout de una reserva aún pending', () async {
      final reservation = await backend.createReservation('p1');

      expect(
        () => backend.checkout(reservation.id),
        throwsA(isA<RepositoryException>().having(
          (e) => e.code,
          'code',
          RepositoryErrorCodes.reservationInvalidState,
        )),
      );
    });

    test('pasada la ventana de llegada, la reserva expira y libera la plaza',
        () async {
      await backend.createReservation('p1');
      expect(backend.findParking('p1')!.availableSpots, 1);

      // El job de expiración del backend actúa al consultar.
      now = now.add(const Duration(minutes: 31));
      final current = await backend.fetchCurrentReservation();

      expect(current, isNull);
      expect(backend.history.first.status, ReservationStatus.expired);
    });
  });
}
