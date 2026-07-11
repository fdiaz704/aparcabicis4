/// Error de la capa de datos.
///
/// Los repositorios lanzan esta excepción en lugar de devolver mensajes de UI,
/// para que la presentación (y su traducción) quede en la capa de widgets.
/// [code] refleja los códigos del contrato (specs/04-API.md), p. ej.
/// `RESERVATION_CONFLICT`, `PARKING_FULL`, `INVALID_CREDENTIALS`.
class RepositoryException implements Exception {
  final String code;
  final String message;

  const RepositoryException(this.code, this.message);

  @override
  String toString() => 'RepositoryException($code): $message';
}

/// Códigos de error usados por los repositorios (fake y, más adelante, API).
abstract final class RepositoryErrorCodes {
  /// No hay sesión iniciada (el endpoint requiere autenticación).
  static const String unauthenticated = 'UNAUTHENTICATED';

  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String invalidEmail = 'INVALID_EMAIL';
  static const String weakPassword = 'WEAK_PASSWORD';
  static const String passwordMismatch = 'PASSWORD_MISMATCH';
  static const String samePassword = 'SAME_PASSWORD';

  /// Ya existe una reserva/uso en curso (RF-3.2; el backend responde 409).
  static const String reservationConflict = 'RESERVATION_CONFLICT';

  /// El aparcamiento no tiene plazas libres.
  static const String parkingFull = 'PARKING_FULL';

  /// La reserva no existe o no está en un estado válido para la operación.
  static const String reservationInvalidState = 'RESERVATION_INVALID_STATE';

  /// La pasarela hardware no respondió (modo degradado, RF-4.7).
  static const String gatewayUnavailable = 'GATEWAY_UNAVAILABLE';
}
