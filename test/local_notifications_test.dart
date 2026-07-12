import 'package:flutter_test/flutter_test.dart';

import 'package:aparcabicis4/models/app_params.dart';
import 'package:aparcabicis4/models/reservation.dart';
import 'package:aparcabicis4/services/local_notifications_service.dart';

/// Un aviso programado, tal y como lo registraría el sistema.
class _Scheduled {
  _Scheduled(this.id, this.when, this.title, this.body);

  final int id;
  final DateTime when;
  final String title;
  final String body;
}

/// Programador falso: registra lo que se programa y se cancela, sin tocar el
/// sistema (en un test no hay AlarmManager ni centro de notificaciones).
class _FakeScheduler implements NotificationScheduler {
  final List<_Scheduled> scheduled = [];
  int cancelAllCalls = 0;

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
    scheduled.add(_Scheduled(id, when, title, body));
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }
}

final _texts = NotificationTexts(
  reservationWarningTitle: 'Tu reserva está a punto de vencer',
  reservationWarningBody: (m) => 'Tu reserva vence en $m min.',
  reservationExpiredTitle: 'Tu reserva ha vencido',
  reservationExpiredBody: 'La plaza ha quedado libre.',
  useWarningTitle: 'Se acaba tu tiempo de uso',
  useWarningBody: (m) => 'Quedan $m min de uso.',
  overstayTitle: 'Has superado el tiempo máximo',
  overstayBody: 'Recoge tu vehículo.',
);

Reservation reservationPending({required DateTime expiresAt}) => Reservation(
      id: 'r1',
      parkingId: 'p1',
      parkingName: 'Chueca',
      status: ReservationStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

Reservation reservationActive({required DateTime maxUntil}) => Reservation(
      id: 'r1',
      parkingId: 'p1',
      parkingName: 'Chueca',
      status: ReservationStatus.active,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      checkinAt: DateTime.now(),
      maxUntil: maxUntil,
    );

void main() {
  late _FakeScheduler plugin;
  late LocalNotificationsService service;

  const params = AppParams.defaults; // avisos {10,5} / {30,15,5} / 30'

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    plugin = _FakeScheduler();
    service = LocalNotificationsService(scheduler: plugin);
  });

  group('avisos de reserva (RF-3.3 / RF-3.4)', () {
    test('programa T−10, T−5 y el vencimiento, contra el expiresAt del servidor',
        () async {
      final expiresAt = DateTime.now().add(const Duration(minutes: 30));
      await service.syncFor(
        reservationPending(expiresAt: expiresAt),
        params,
        _texts,
      );

      expect(plugin.scheduled, hasLength(3));

      final times = plugin.scheduled.map((s) => s.when).toList()..sort();
      // T−10' y T−5' del vencimiento, y el vencimiento mismo.
      expect(
        times[0].difference(expiresAt).inMinutes,
        closeTo(-10, 1),
      );
      expect(times[1].difference(expiresAt).inMinutes, closeTo(-5, 1));
      expect(times[2].difference(expiresAt).inMinutes.abs(), lessThanOrEqualTo(1));
    });

    test('los avisos que ya han pasado no se programan', () async {
      // Ventana de solo 2 minutos: los avisos de T−10 y T−5 caen en el pasado.
      final expiresAt = DateTime.now().add(const Duration(minutes: 2));
      await service.syncFor(
        reservationPending(expiresAt: expiresAt),
        params,
        _texts,
      );

      // Solo queda el aviso de vencimiento.
      expect(plugin.scheduled, hasLength(1));
      expect(plugin.scheduled.single.title, 'Tu reserva ha vencido');
    });
  });

  group('avisos de uso (RF-4.4)', () {
    test('programa T−30, T−15, T−5 y la serie de exceso cada 30 min', () async {
      final maxUntil = DateTime.now().add(const Duration(hours: 14));
      await service.syncFor(
        reservationActive(maxUntil: maxUntil),
        params,
        _texts,
      );

      // 3 avisos previos + las repeticiones tras superar el tiempo.
      expect(
        plugin.scheduled,
        hasLength(3 + LocalNotificationsService.overstayOccurrences),
      );

      final warnings = plugin.scheduled
          .where((s) => s.title == 'Se acaba tu tiempo de uso')
          .map((s) => maxUntil.difference(s.when).inMinutes)
          .toList()
        ..sort();
      expect(warnings, [5, 15, 30]);

      final overstay = plugin.scheduled
          .where((s) => s.title == 'Has superado el tiempo máximo')
          .map((s) => s.when.difference(maxUntil).inMinutes)
          .toList()
        ..sort();
      // Cada 30 minutos tras el vencimiento: 30, 60, 90...
      expect(overstay.first, closeTo(30, 1));
      expect(overstay[1] - overstay[0], closeTo(30, 1));
    });

    test('una reserva activa sin maxUntil no programa avisos de uso', () async {
      // Se construye directamente: copyWith no puede poner un campo a null.
      final reservation = Reservation(
        id: 'r1',
        parkingId: 'p1',
        parkingName: 'Chueca',
        status: ReservationStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        checkinAt: DateTime.now(),
      );

      await service.syncFor(reservation, params, _texts);
      expect(plugin.scheduled, isEmpty);
    });
  });

  group('cancelación (RF-4.5)', () {
    test('sin reserva se cancela toda la serie', () async {
      await service.syncFor(
        reservationPending(
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
        params,
        _texts,
      );
      expect(plugin.scheduled, isNotEmpty);

      // Checkout / cancelación / vencimiento: ya no hay reserva.
      await service.syncFor(null, params, _texts);

      expect(plugin.scheduled, isEmpty);
      expect(plugin.cancelAllCalls, greaterThanOrEqualTo(2));
    });

    test('una reserva ya finalizada no programa nada', () async {
      final completed = reservationPending(
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      ).copyWith(status: ReservationStatus.completed);

      await service.syncFor(completed, params, _texts);
      expect(plugin.scheduled, isEmpty);
    });

    test('reprogramar sustituye la serie anterior, no la duplica', () async {
      final reservation = reservationPending(
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      await service.syncFor(reservation, params, _texts);
      final first = plugin.scheduled.length;

      // Nueva sincronización con el servidor (mismo estado).
      await service.syncFor(reservation, params, _texts);

      expect(plugin.scheduled, hasLength(first));
    });
  });
}
