import '../models/access_result.dart';

/// Control de acceso: apertura de puerta (specs/04-API.md, RF-4).
abstract interface class AccessRepository {
  /// `POST /reservations/{id}/open`.
  ///
  /// El backend valida la reserva y ordena la apertura a la pasarela hardware,
  /// respondiendo `opened`/`failed`/`timeout` en <5 s (RF-4.2). Un open exitoso
  /// sobre una reserva `pending` provoca el **check-in** (pending → active) en
  /// el servidor: tras llamarlo, la app debe resincronizar la reserva actual.
  ///
  /// Lanza [RepositoryException] con `RESERVATION_INVALID_STATE` si la reserva
  /// no admite apertura.
  Future<AccessResult> openDoor(String reservationId);
}
