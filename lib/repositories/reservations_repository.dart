import '../models/reservation.dart';

/// Acceso a reservas (specs/04-API.md). El backend es la fuente de verdad de
/// estados y tiempos; la app solo sincroniza y pinta cuentas atrás.
abstract interface class ReservationsRepository {
  /// `POST /reservations` con `{parkingId}` → reserva `pending`.
  ///
  /// Lanza [RepositoryException] con `RESERVATION_CONFLICT` si ya hay una
  /// reserva/uso en curso (RF-3.2) o `PARKING_FULL` si no quedan plazas.
  Future<Reservation> createReservation(String parkingId);

  /// `GET /reservations/current`: reserva `pending`/`active`, o null.
  ///
  /// También sincroniza el vencimiento: una reserva `pending` cuya ventana de
  /// llegada ha expirado pasa a `expired` (en el backend real lo hace el job
  /// de expiración por cron).
  Future<Reservation?> getCurrentReservation();

  /// `POST /reservations/{id}/cancel`: solo desde `pending` (RF-3.5).
  Future<Reservation> cancelReservation(String reservationId);

  /// `POST /reservations/{id}/checkout`: solo desde `active`, tras confirmar
  /// el usuario que ha retirado el vehículo (RF-4.5).
  Future<Reservation> checkout(String reservationId);

  /// `GET /reservations`: historial (por defecto, últimos 3 meses).
  Future<List<Reservation>> getHistory();
}
