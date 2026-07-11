import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/models/access_result.dart';
import 'package:aparcabicis4/models/reservation.dart';
import 'package:aparcabicis4/providers/reservations_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_access_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_reservations_repository.dart';
import 'package:aparcabicis4/repositories/repository_exception.dart';
import 'package:aparcabicis4/services/storage_service.dart';

void main() {
  late FakeBackend backend;

  ReservationsProvider providerWith(FakeAccessRepository access) {
    return ReservationsProvider(
      reservationsRepository: FakeReservationsRepository(backend),
      accessRepository: access,
    );
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();

    backend = FakeBackend(
      seedParkings: demoCity.seedParkings,
      latency: Duration.zero,
    );
  });

  test('flujo completo: reservar → abrir (check-in) → abrir + checkout',
      () async {
    final provider = providerWith(FakeAccessRepository(backend));
    final parking =
        demoCity.seedParkings.firstWhere((p) => p.availableSpots > 0);

    // 1. Reservar: queda pending y bloquea nuevas reservas.
    final error = await provider.createReservation(parking);
    expect(error, isNull);
    expect(provider.hasActiveReservation, isTrue);
    expect(provider.activeReservation!.status, ReservationStatus.pending);
    expect(provider.reservationState, ReservationState.reserved);

    // 2. Abrir puerta: check-in (pending → active) y arranca el uso.
    final checkin = await provider.openDoor();
    expect(checkin.isOpened, isTrue);
    expect(provider.activeReservation!.status, ReservationStatus.active);
    expect(provider.reservationState, ReservationState.inUse);
    expect(provider.activeReservation!.checkinAt, isNotNull);
    // El tiempo máximo lo fija el servidor (840 min), no la app.
    expect(provider.maxUsageSeconds, 840 * 60);

    // 3. Abrir de nuevo para retirar el vehículo: sigue activa.
    final reopen = await provider.openDoor();
    expect(reopen.isOpened, isTrue);
    expect(provider.activeReservation!.status, ReservationStatus.active);

    // 4. Confirmar retirada ⇒ checkout: completed y al historial.
    final finished = await provider.finishUsage();
    expect(finished, isTrue);
    expect(provider.hasActiveReservation, isFalse);
    expect(provider.reservationHistory.first.status,
        ReservationStatus.completed);
  });

  test('una segunda reserva devuelve RESERVATION_CONFLICT (RF-3.2)', () async {
    final provider = providerWith(FakeAccessRepository(backend));
    final parkings =
        demoCity.seedParkings.where((p) => p.availableSpots > 0).toList();

    expect(await provider.createReservation(parkings[0]), isNull);
    expect(
      await provider.createReservation(parkings[1]),
      RepositoryErrorCodes.reservationConflict,
    );
  });

  test('reservar un aparcamiento sin plazas devuelve PARKING_FULL', () async {
    final provider = providerWith(FakeAccessRepository(backend));
    final full =
        demoCity.seedParkings.firstWhere((p) => p.availableSpots == 0);

    expect(
      await provider.createReservation(full),
      RepositoryErrorCodes.parkingFull,
    );
    expect(provider.hasActiveReservation, isFalse);
  });

  test('cancelar antes del check-in deja la reserva como cancelled (RF-3.5)',
      () async {
    final provider = providerWith(FakeAccessRepository(backend));
    final parking =
        demoCity.seedParkings.firstWhere((p) => p.availableSpots > 0);

    await provider.createReservation(parking);
    expect(await provider.cancelReservation(), isTrue);

    expect(provider.hasActiveReservation, isFalse);
    expect(provider.reservationHistory.first.status,
        ReservationStatus.cancelled);
  });

  test('si la pasarela no responde, el estado de la reserva NO cambia (RF-4.7)',
      () async {
    // Pasarela degradada: devuelve timeout.
    final provider = providerWith(
      FakeAccessRepository(backend, simulatedStatus: AccessStatus.timeout),
    );
    final parking =
        demoCity.seedParkings.firstWhere((p) => p.availableSpots > 0);

    await provider.createReservation(parking);
    final result = await provider.openDoor();

    expect(result.isOpened, isFalse);
    expect(result.isDegraded, isTrue);
    // No hay check-in: la reserva sigue pendiente.
    expect(provider.activeReservation!.status, ReservationStatus.pending);
    expect(provider.activeReservation!.checkinAt, isNull);
  });
}
