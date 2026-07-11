import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/access_result.dart';
import '../models/parking.dart';
import '../models/reservation.dart';
import '../repositories/access_repository.dart';
import '../repositories/repository_exception.dart';
import '../repositories/reservations_repository.dart';

/// Estado visible de la reserva en curso, para la UI.
enum ReservationState { reserved, inUse }

/// Reserva en curso e historial.
///
/// El **backend es la fuente de verdad**: los estados y los tiempos
/// (`expiresAt`, `maxUntil`) vienen de la reserva servida por el repositorio.
/// El temporizador local es solo una cuenta atrás visual sincronizada con
/// esas marcas; no decide nada.
class ReservationsProvider with ChangeNotifier {
  ReservationsProvider({
    required ReservationsRepository reservationsRepository,
    required AccessRepository accessRepository,
  })  : _reservationsRepository = reservationsRepository,
        _accessRepository = accessRepository;

  final ReservationsRepository _reservationsRepository;
  final AccessRepository _accessRepository;

  Reservation? _current;
  List<Reservation> _history = [];
  Timer? _ticker;

  Reservation? get activeReservation => _current;
  bool get hasActiveReservation => _current != null;
  List<Reservation> get reservationHistory => _history;

  /// Estado para la UI: `pending` ⇒ reservada, `active` ⇒ en uso.
  ReservationState get reservationState =>
      _current?.status == ReservationStatus.active
          ? ReservationState.inUse
          : ReservationState.reserved;

  /// Segundos que faltan para que venza la ventana de llegada (RF-3.1).
  int get reservationTimeLeft {
    final current = _current;
    if (current == null) return 0;
    final left = current.expiresAt.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  /// Segundos transcurridos de uso desde el check-in.
  int get usageTime {
    final checkinAt = _current?.checkinAt;
    if (checkinAt == null) return 0;
    final elapsed = DateTime.now().difference(checkinAt).inSeconds;
    return elapsed > 0 ? elapsed : 0;
  }

  /// Duración máxima de uso concedida por el servidor, en segundos.
  int get maxUsageSeconds {
    final current = _current;
    final checkinAt = current?.checkinAt;
    final maxUntil = current?.maxUntil;
    if (checkinAt == null || maxUntil == null) return 0;
    return maxUntil.difference(checkinAt).inSeconds;
  }

  /// Carga la reserva en curso y el historial desde el repositorio.
  Future<void> initialize() async {
    await syncCurrent();
    await refreshHistory();
  }

  /// Resincroniza la reserva en curso con el servidor (fuente de verdad).
  Future<void> syncCurrent() async {
    try {
      _current = await _reservationsRepository.getCurrentReservation();
      _restartTicker();
      notifyListeners();
    } catch (e) {
      debugPrint('Sync current reservation error: $e');
    }
  }

  Future<void> refreshHistory() async {
    try {
      _history = await _reservationsRepository.getHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh history error: $e');
    }
  }

  /// Crea una reserva (`pending`). Devuelve el código de error del contrato si
  /// falla (p. ej. `RESERVATION_CONFLICT`, `PARKING_FULL`), o null si va bien.
  Future<String?> createReservation(Parking parking) async {
    try {
      _current = await _reservationsRepository.createReservation(parking.id);
      _restartTicker();
      notifyListeners();
      return null;
    } on RepositoryException catch (e) {
      debugPrint('Create reservation error: $e');
      return e.code;
    } catch (e) {
      debugPrint('Create reservation error: $e');
      return 'UNKNOWN';
    }
  }

  /// Cancela la reserva antes del check-in (RF-3.5).
  Future<bool> cancelReservation() async {
    final current = _current;
    if (current == null) return false;

    try {
      await _reservationsRepository.cancelReservation(current.id);
      _current = null;
      _stopTicker();
      await refreshHistory();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Cancel reservation error: $e');
      return false;
    }
  }

  /// Abre la puerta (RF-4.2). El primer open exitoso sobre una reserva
  /// `pending` provoca el check-in en el servidor, así que resincronizamos.
  Future<AccessResult> openDoor() async {
    final current = _current;
    if (current == null) {
      return const AccessResult(status: AccessStatus.failed);
    }

    try {
      final result = await _accessRepository.openDoor(current.id);
      if (result.isOpened) {
        await syncCurrent();
      }
      return result;
    } on RepositoryException catch (e) {
      debugPrint('Open door error: $e');
      return const AccessResult(status: AccessStatus.failed);
    } catch (e) {
      debugPrint('Open door error: $e');
      return const AccessResult(status: AccessStatus.failed);
    }
  }

  /// Finaliza el uso tras confirmar la retirada del vehículo (RF-4.5).
  Future<bool> finishUsage() async {
    final current = _current;
    if (current == null) return false;

    try {
      await _reservationsRepository.checkout(current.id);
      _current = null;
      _stopTicker();
      await refreshHistory();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Finish usage error: $e');
      return false;
    }
  }

  // --- Temporizador visual ---------------------------------------------

  void _restartTicker() {
    _stopTicker();
    if (_current == null) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      // Si venció la ventana de llegada, el servidor ya la habrá expirado:
      // resincronizamos en lugar de decidirlo localmente (RF-3.4).
      if (_current?.status == ReservationStatus.pending &&
          reservationTimeLeft <= 0) {
        await syncCurrent();
        await refreshHistory();
        return;
      }
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  // --- Formato ----------------------------------------------------------

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    return '${minutes}m ${secs}s';
  }

  String formatDurationMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  // --- Estadísticas (derivadas del historial) ---------------------------

  Map<String, dynamic> getStatistics() {
    final total = _history.length;
    final completed =
        _history.where((r) => r.status == ReservationStatus.completed).length;
    final cancelled =
        _history.where((r) => r.status == ReservationStatus.cancelled).length;
    final expired =
        _history.where((r) => r.status == ReservationStatus.expired).length;

    final totalUsageTime = _history.fold<int>(
      0,
      (sum, r) => sum + r.durationMinutes * 60,
    );
    final averageUsageTime = completed > 0 ? totalUsageTime ~/ completed : 0;
    final completionRate =
        total > 0 ? ((completed / total) * 100).round() : 0;
    final cancellationRate =
        total > 0 ? ((cancelled / total) * 100).round() : 0;

    // Ahorro estimado (2 €/hora frente al transporte público).
    final totalSavings = (totalUsageTime / 3600) * 2.0;

    return {
      'totalReservations': total,
      'completedReservations': completed,
      'cancelledReservations': cancelled,
      'expiredReservations': expired,
      'totalUsageTime': totalUsageTime,
      'averageUsageTime': averageUsageTime,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
      'totalSavings': totalSavings,
      'bestMonth': total,
    };
  }

  Map<String, dynamic> getReservationStatistics() {
    final total = _history.length;
    final completed =
        _history.where((r) => r.status == ReservationStatus.completed).toList();
    final totalMinutes =
        completed.fold<int>(0, (sum, r) => sum + r.durationMinutes);
    final averageDuration =
        completed.isNotEmpty ? (totalMinutes / completed.length).round() : 0;

    return {
      'total': total,
      'completed': completed.length,
      'averageDuration': averageDuration,
    };
  }

  Map<String, dynamic> getUserStatistics() {
    final completed =
        _history.where((r) => r.status == ReservationStatus.completed);
    final totalMinutes =
        completed.fold<int>(0, (sum, r) => sum + r.durationMinutes);

    final frequency = <String, int>{};
    for (final reservation in _history) {
      frequency[reservation.parkingName] =
          (frequency[reservation.parkingName] ?? 0) + 1;
    }

    var favoriteParking = 'Ninguno aún';
    if (frequency.isNotEmpty) {
      favoriteParking = frequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      'totalReservations': _history.length,
      'totalTimeMinutes': totalMinutes,
      'favoriteParking': favoriteParking,
    };
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
