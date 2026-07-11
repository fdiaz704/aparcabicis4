import 'app_params.dart';
import 'reservation.dart';
import 'user.dart';

/// Estadísticas de uso del usuario servidas en `GET /bootstrap`.
class UserStats {
  final int totalUses;
  final int totalMinutes;
  final String? favoriteParkingId;

  const UserStats({
    this.totalUses = 0,
    this.totalMinutes = 0,
    this.favoriteParkingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalUses': totalUses,
      'totalMinutes': totalMinutes,
      'favoriteParkingId': favoriteParkingId,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalUses: (json['totalUses'] as int?) ?? 0,
      totalMinutes: (json['totalMinutes'] as int?) ?? 0,
      favoriteParkingId: json['favoriteParkingId'] as String?,
    );
  }
}

/// Respuesta completa de `GET /bootstrap` (specs/04-API.md, RF-B.1).
///
/// Una sola llamada tras login o restauración de sesión: perfil, parámetros
/// del sistema, estadísticas y **uso actual** (reserva `pending`/`active` o null).
class BootstrapData {
  final User user;
  final AppParams params;
  final UserStats stats;

  /// Reserva en curso, o null si el usuario no tiene ninguna (RF-B.3).
  final Reservation? currentReservation;

  const BootstrapData({
    required this.user,
    required this.params,
    required this.stats,
    this.currentReservation,
  });

  /// Si hay uso en curso, la app navega directamente al uso activo y bloquea
  /// nuevas reservas (RF-B.3).
  bool get hasOngoingReservation => currentReservation != null;

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'params': params.toJson(),
      'stats': stats.toJson(),
      'currentReservation': currentReservation?.toJson(),
    };
  }

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    final current = json['currentReservation'] as Map<String, dynamic>?;
    return BootstrapData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      params: AppParams.fromJson(json['params'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      currentReservation: current == null ? null : Reservation.fromJson(current),
    );
  }
}
