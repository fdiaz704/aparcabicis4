import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_params.dart';
import '../models/reservation.dart';

/// Textos de los avisos. Los aporta la UI ya traducidos: el servicio no conoce
/// las localizaciones (no tiene BuildContext).
class NotificationTexts {
  const NotificationTexts({
    required this.reservationWarningTitle,
    required this.reservationWarningBody,
    required this.reservationExpiredTitle,
    required this.reservationExpiredBody,
    required this.useWarningTitle,
    required this.useWarningBody,
    required this.overstayTitle,
    required this.overstayBody,
  });

  final String reservationWarningTitle;

  /// Recibe los minutos que faltan.
  final String Function(int minutes) reservationWarningBody;

  final String reservationExpiredTitle;
  final String reservationExpiredBody;

  final String useWarningTitle;

  /// Recibe los minutos que faltan para el fin del uso.
  final String Function(int minutes) useWarningBody;

  final String overstayTitle;
  final String overstayBody;
}

/// Programador de avisos del sistema.
///
/// Tras una interfaz porque `FlutterLocalNotificationsPlugin` es un singleton
/// con constructor factory: no se puede extender ni falsear. Con esto, los
/// tests comprueban QUÉ se programa y QUÉ se cancela sin tocar el sistema.
abstract interface class NotificationScheduler {
  Future<void> initialize();

  /// Permiso de notificaciones (Android 13+, iOS) y de alarmas exactas.
  Future<bool> requestPermissions();

  /// Programa un aviso en un instante concreto, con alarma exacta para que
  /// salte con la app cerrada.
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  });

  /// Cancela los avisos **aún no disparados**.
  ///
  /// Importante: NO toca las notificaciones ya mostradas. `cancelAll()` del
  /// plugin sí las borra, y eso hacía que un aviso apareciera y se esfumara
  /// al instante (la app resincroniza justo cuando el aviso salta).
  Future<void> cancelPending();
}

/// Implementación real sobre `flutter_local_notifications`.
class PluginNotificationScheduler implements NotificationScheduler {
  PluginNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'reservas',
    'Reservas y uso',
    channelDescription: 'Avisos de vencimiento de reserva y de fin de uso',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  // Los avisos son accesorios: si el plugin del sistema falla (plataforma sin
  // soporte, permiso revocado, entorno de test...), se registra y se sigue. Un
  // fallo aquí NUNCA debe tumbar el arranque ni el flujo de reserva.

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('No se pudo inicializar el sistema de avisos: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        // Sin alarmas exactas, el aviso no salta a su hora con la app cerrada.
        await android.requestExactAlarmsPermission();
        return granted ?? false;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('No se pudo pedir el permiso de avisos: $e');
    }
    return false;
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        _details,
        // Alarma exacta, también con el móvil en reposo (RF-4.4).
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Sin permiso de alarmas exactas el sistema puede rechazarlas: se registra
      // y se sigue, en vez de romper el flujo de reserva.
      debugPrint('No se pudo programar el aviso $id: $e');
    }
  }

  @override
  Future<void> cancelPending() async {
    try {
      // Los ya mostrados no están en la lista de pendientes, así que
      // cancelándolos uno a uno no se borran de la barra de notificaciones.
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        await _plugin.cancel(request.id);
      }
    } catch (e) {
      debugPrint('No se pudieron cancelar los avisos pendientes: $e');
    }
  }
}

/// Avisos locales de reserva y uso (RF-3.3, RF-3.4, RF-4.4).
///
/// Se programan como **alarmas exactas del sistema** contra `expiresAt` y
/// `maxUntil` **que sirve el servidor**, de modo que saltan aunque la app esté
/// cerrada. No hay temporizadores en memoria: la app solo (re)programa y
/// cancela.
///
/// Reglas (los offsets vienen de [AppParams], no se hardcodean):
/// - Reserva: avisos a T−10' y T−5' del vencimiento, y aviso al vencer.
/// - Uso: avisos a T−30', T−15' y T−5' de `maxUntil`; superado el tiempo,
///   aviso cada 30'.
class LocalNotificationsService {
  LocalNotificationsService({NotificationScheduler? scheduler})
      : _scheduler = scheduler ?? PluginNotificationScheduler();

  final NotificationScheduler _scheduler;

  /// IDs reservados por familia, para poder identificar cada aviso.
  static const int _reservationBaseId = 1000;
  static const int _expiredId = 1099;
  static const int _useBaseId = 2000;
  static const int _overstayBaseId = 3000;

  /// Cuántos avisos de exceso se dejan programados por adelantado (una serie
  /// repetitiva no puede arrancar en un instante futuro concreto).
  static const int overstayOccurrences = 8;

  Future<void> initialize() => _scheduler.initialize();

  Future<bool> requestPermissions() async {
    await initialize();
    return _scheduler.requestPermissions();
  }

  /// Reprograma **toda** la serie de avisos para la reserva en curso.
  ///
  /// Se llama en cada sincronización con el servidor: cancela lo que hubiera y
  /// programa lo que corresponda al estado actual. Si no hay reserva (checkout,
  /// cancelación o vencimiento), lo cancela todo (RF-4.5).
  Future<void> syncFor(
    Reservation? reservation,
    AppParams params,
    NotificationTexts texts,
  ) async {
    await initialize();
    await _scheduler.cancelPending();

    if (reservation == null) return;

    switch (reservation.status) {
      case ReservationStatus.pending:
        await _scheduleReservationSeries(reservation, params, texts);
      case ReservationStatus.active:
        await _scheduleUseSeries(reservation, params, texts);
      case ReservationStatus.completed:
      case ReservationStatus.cancelled:
      case ReservationStatus.expired:
        break;
    }
  }

  /// Ventana de llegada: avisos a T−10' y T−5', y aviso al vencer (RF-3.3/3.4).
  Future<void> _scheduleReservationSeries(
    Reservation reservation,
    AppParams params,
    NotificationTexts texts,
  ) async {
    final expiresAt = reservation.expiresAt;

    for (var i = 0; i < params.reservationWarningsMin.length; i++) {
      final minutesBefore = params.reservationWarningsMin[i];
      await _scheduleAt(
        id: _reservationBaseId + i,
        when: expiresAt.subtract(Duration(minutes: minutesBefore)),
        title: texts.reservationWarningTitle,
        body: texts.reservationWarningBody(minutesBefore),
      );
    }

    await _scheduleAt(
      id: _expiredId,
      when: expiresAt,
      title: texts.reservationExpiredTitle,
      body: texts.reservationExpiredBody,
    );
  }

  /// Fin de uso: avisos a T−30', T−15' y T−5' de `maxUntil` y, superado el
  /// tiempo máximo, aviso cada `overstayIntervalMin` (RF-4.4).
  Future<void> _scheduleUseSeries(
    Reservation reservation,
    AppParams params,
    NotificationTexts texts,
  ) async {
    final maxUntil = reservation.maxUntil;
    if (maxUntil == null) return;

    for (var i = 0; i < params.useWarningsMin.length; i++) {
      final minutesBefore = params.useWarningsMin[i];
      await _scheduleAt(
        id: _useBaseId + i,
        when: maxUntil.subtract(Duration(minutes: minutesBefore)),
        title: texts.useWarningTitle,
        body: texts.useWarningBody(minutesBefore),
      );
    }

    for (var i = 1; i <= overstayOccurrences; i++) {
      await _scheduleAt(
        id: _overstayBaseId + i,
        when: maxUntil.add(Duration(minutes: params.overstayIntervalMin * i)),
        title: texts.overstayTitle,
        body: texts.overstayBody,
      );
    }
  }

  /// Programa un aviso. Los que caen en el pasado se descartan (p. ej. si se
  /// reserva con menos de 10 minutos de ventana restante).
  Future<void> _scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (!when.isAfter(DateTime.now())) return;
    await _scheduler.scheduleAt(id: id, when: when, title: title, body: body);
  }

  /// Cancela los avisos pendientes (checkout, cancelación o vencimiento).
  ///
  /// Los ya mostrados se conservan: el usuario debe poder leerlos.
  Future<void> cancelPending() async {
    await initialize();
    await _scheduler.cancelPending();
  }
}
