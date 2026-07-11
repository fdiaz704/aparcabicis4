import 'package:flutter/foundation.dart';

import '../../models/app_params.dart';
import '../../models/bootstrap_data.dart';
import '../../models/parking.dart';
import '../../models/reservation.dart';
import '../../models/user.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../repository_exception.dart';

/// Backend simulado en memoria, compartido por todos los repositorios `Fake*`.
///
/// Reproduce el comportamiento del backend real descrito en las specs: es la
/// **fuente de verdad** de la máquina de estados de reservas
/// (`pending → active → completed | cancelled | expired`, specs/03) y de los
/// parámetros del sistema (ventana 30', uso 840', avisos {10,5}/{30,15,5}/30').
///
/// Persiste favoritos, historial y reserva en curso a través de
/// [StorageService] (único punto de persistencia local), de modo que sobreviven
/// a un reinicio igual que lo harían en el servidor.
class FakeBackend {
  FakeBackend({
    required List<Parking> seedParkings,
    this.params = AppParams.defaults,
    this.latency = const Duration(milliseconds: 300),
    DateTime Function()? clock,
  })  : _parkings = List<Parking>.from(seedParkings),
        _clock = clock ?? DateTime.now;

  /// Parámetros del sistema que sirve el bootstrap.
  final AppParams params;

  /// Latencia simulada de red.
  final Duration latency;

  /// Reloj del "servidor". Inyectable para poder probar el vencimiento de la
  /// ventana de llegada sin esperar en tiempo real.
  final DateTime Function() _clock;

  final List<Parking> _parkings;
  final Set<String> _favoriteIds = <String>{};
  Reservation? _currentReservation;
  List<Reservation> _history = <Reservation>[];

  /// Usuario con sesión iniciada (lo fija [FakeAuthRepository] en el login).
  User? currentUser;

  bool _loaded = false;

  List<Parking> get parkings => List<Parking>.unmodifiable(_parkings);
  Set<String> get favoriteIds => Set<String>.unmodifiable(_favoriteIds);
  List<Reservation> get history => List<Reservation>.unmodifiable(_history);

  /// Estadísticas de uso que sirve el bootstrap, derivadas del historial.
  UserStats get stats {
    final completed =
        _history.where((r) => r.status == ReservationStatus.completed).toList();
    final totalMinutes =
        completed.fold<int>(0, (sum, r) => sum + r.durationMinutes);

    String? favoriteParkingId;
    if (_favoriteIds.isNotEmpty) {
      favoriteParkingId = _favoriteIds.first;
    }

    return UserStats(
      totalUses: completed.length,
      totalMinutes: totalMinutes,
      favoriteParkingId: favoriteParkingId,
    );
  }

  /// Carga el estado persistido. Idempotente.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final favorites = StorageService.getStringList(AppConstants.prefKeyFavorites);
    if (favorites != null) {
      _favoriteIds.addAll(favorites);
    }

    _history = _readReservations(AppConstants.prefKeyHistory);

    final current = StorageService.getJson(AppConstants.prefKeyCurrentReservation);
    if (current != null) {
      try {
        _currentReservation = Reservation.fromJson(current);
      } catch (e) {
        // Formato antiguo o corrupto: se descarta.
        debugPrint('FakeBackend: reserva en curso ilegible, se descarta ($e)');
        await StorageService.remove(AppConstants.prefKeyCurrentReservation);
      }
    }
  }

  List<Reservation> _readReservations(String key) {
    final raw = StorageService.getJsonList(key);
    if (raw == null) return <Reservation>[];
    try {
      return raw.map(Reservation.fromJson).toList();
    } catch (e) {
      // El historial anterior usaba otro formato (ReservationRecord). Se
      // descarta en lugar de romper el arranque.
      debugPrint('FakeBackend: historial en formato antiguo, se descarta ($e)');
      return <Reservation>[];
    }
  }

  Future<void> _persistFavorites() =>
      StorageService.setStringList(AppConstants.prefKeyFavorites, _favoriteIds.toList());

  Future<void> _persistHistory() => StorageService.setJsonList(
        AppConstants.prefKeyHistory,
        _history.map((r) => r.toJson()).toList(),
      );

  Future<void> _persistCurrent() async {
    final current = _currentReservation;
    if (current == null) {
      await StorageService.remove(AppConstants.prefKeyCurrentReservation);
    } else {
      await StorageService.setJson(
        AppConstants.prefKeyCurrentReservation,
        current.toJson(),
      );
    }
  }

  /// Simula la latencia de red de una llamada a la API.
  Future<void> _network() => Future<void>.delayed(latency);

  // --- Parkings ---------------------------------------------------------

  Future<List<Parking>> fetchParkings() async {
    await _network();
    return parkings;
  }

  Parking? findParking(String parkingId) {
    for (final parking in _parkings) {
      if (parking.id == parkingId) return parking;
    }
    return null;
  }

  Future<void> setFavorite(String parkingId, {required bool favorite}) async {
    await _network();
    if (favorite) {
      _favoriteIds.add(parkingId);
    } else {
      _favoriteIds.remove(parkingId);
    }
    await _persistFavorites();
  }

  // --- Reservas ---------------------------------------------------------

  /// Expira la reserva en curso si venció su ventana de llegada. Es lo que en
  /// el backend real hace el job de expiración (cron del hosting).
  Future<void> _expireIfDue() async {
    final current = _currentReservation;
    if (current == null) return;
    if (current.status != ReservationStatus.pending) return;

    if (!_clock().isBefore(current.expiresAt)) {
      final expired = current.copyWith(status: ReservationStatus.expired);
      _history.insert(0, expired);
      _currentReservation = null;
      await _persistHistory();
      await _persistCurrent();
    }
  }

  Future<Reservation?> fetchCurrentReservation() async {
    await _network();
    await _expireIfDue();
    return _currentReservation;
  }

  Future<Reservation> createReservation(String parkingId) async {
    await _network();
    await _expireIfDue();

    if (_currentReservation != null) {
      throw const RepositoryException(
        RepositoryErrorCodes.reservationConflict,
        'Ya existe una reserva o uso en curso.',
      );
    }

    final parking = findParking(parkingId);
    if (parking == null) {
      throw const RepositoryException(
        RepositoryErrorCodes.reservationInvalidState,
        'El aparcamiento no existe.',
      );
    }
    if (parking.availableSpots <= 0) {
      throw const RepositoryException(
        RepositoryErrorCodes.parkingFull,
        'No quedan plazas libres en el aparcamiento.',
      );
    }

    final now = _clock();
    final reservation = Reservation(
      id: 'res-${now.microsecondsSinceEpoch}',
      parkingId: parking.id,
      parkingName: parking.name,
      parkingAddress: parking.address,
      status: ReservationStatus.pending,
      createdAt: now,
      expiresAt: now.add(params.reservationWindow),
    );

    _currentReservation = reservation;
    _occupySpot(parking.id);
    await _persistCurrent();
    return reservation;
  }

  /// Apertura de puerta. Sobre una reserva `pending` provoca el check-in
  /// (pending → active) y arranca la cuenta de `maxUntil` (RF-4.3).
  Future<Reservation> openDoor(String reservationId) async {
    await _network();
    await _expireIfDue();

    final current = _currentReservation;
    if (current == null || current.id != reservationId || !current.isOngoing) {
      throw const RepositoryException(
        RepositoryErrorCodes.reservationInvalidState,
        'La reserva no admite apertura de puerta.',
      );
    }

    if (current.status == ReservationStatus.pending) {
      final now = _clock();
      _currentReservation = current.copyWith(
        status: ReservationStatus.active,
        checkinAt: now,
        maxUntil: now.add(params.maxUse),
      );
      await _persistCurrent();
    }
    // Durante `active` la puerta puede abrirse cuantas veces haga falta sin
    // cambiar el estado.
    return _currentReservation!;
  }

  Future<Reservation> cancelReservation(String reservationId) async {
    await _network();
    await _expireIfDue();

    final current = _currentReservation;
    if (current == null ||
        current.id != reservationId ||
        current.status != ReservationStatus.pending) {
      throw const RepositoryException(
        RepositoryErrorCodes.reservationInvalidState,
        'Solo se puede cancelar una reserva pendiente de check-in.',
      );
    }

    final cancelled = current.copyWith(status: ReservationStatus.cancelled);
    _history.insert(0, cancelled);
    _currentReservation = null;
    _releaseSpot(cancelled.parkingId);
    await _persistHistory();
    await _persistCurrent();
    return cancelled;
  }

  Future<Reservation> checkout(String reservationId) async {
    await _network();

    final current = _currentReservation;
    if (current == null ||
        current.id != reservationId ||
        current.status != ReservationStatus.active) {
      throw const RepositoryException(
        RepositoryErrorCodes.reservationInvalidState,
        'Solo se puede finalizar un uso activo.',
      );
    }

    final completed = current.copyWith(
      status: ReservationStatus.completed,
      checkoutAt: _clock(),
    );
    _history.insert(0, completed);
    _currentReservation = null;
    _releaseSpot(completed.parkingId);
    await _persistHistory();
    await _persistCurrent();
    return completed;
  }

  Future<List<Reservation>> fetchHistory() async {
    await _network();
    return history;
  }

  // --- Ocupación --------------------------------------------------------
  //
  // El backend real deriva `available_spots` de las reservas en curso
  // (specs/03). Aquí lo simulamos ajustando el contador del parking.

  void _occupySpot(String parkingId) => _adjustSpots(parkingId, -1);

  void _releaseSpot(String parkingId) => _adjustSpots(parkingId, 1);

  void _adjustSpots(String parkingId, int delta) {
    final index = _parkings.indexWhere((p) => p.id == parkingId);
    if (index == -1) return;
    final parking = _parkings[index];
    final updated = (parking.availableSpots + delta).clamp(0, parking.totalSpots);
    _parkings[index] = parking.copyWith(availableSpots: updated);
  }
}
