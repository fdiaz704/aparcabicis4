/// Parámetros del sistema servidos por el backend en `GET /bootstrap`
/// (specs/04-API.md, RF-B.2).
///
/// Regla: la app NO hardcodea tiempos. Todos los tiempos de reserva/uso y los
/// offsets de aviso vienen de aquí.
class AppParams {
  /// Ventana de llegada de la reserva, en minutos (p. ej. 30).
  final int reservationWindowMin;

  /// Tiempo máximo de uso de la plaza, en minutos (p. ej. 840 = 14 h).
  final int maxUseMin;

  /// Offsets de aviso antes del vencimiento de la reserva (p. ej. [10, 5]).
  final List<int> reservationWarningsMin;

  /// Offsets de aviso antes del fin del uso (p. ej. [30, 15, 5]).
  final List<int> useWarningsMin;

  /// Intervalo de aviso repetido tras exceder el uso máximo (p. ej. 30).
  final int overstayIntervalMin;

  const AppParams({
    required this.reservationWindowMin,
    required this.maxUseMin,
    required this.reservationWarningsMin,
    required this.useWarningsMin,
    required this.overstayIntervalMin,
  });

  /// Valores por defecto acordados en la spec (fase 1, contra fakes).
  static const AppParams defaults = AppParams(
    reservationWindowMin: 30,
    maxUseMin: 840,
    reservationWarningsMin: [10, 5],
    useWarningsMin: [30, 15, 5],
    overstayIntervalMin: 30,
  );

  Duration get reservationWindow => Duration(minutes: reservationWindowMin);
  Duration get maxUse => Duration(minutes: maxUseMin);

  Map<String, dynamic> toJson() {
    return {
      'reservationWindowMin': reservationWindowMin,
      'maxUseMin': maxUseMin,
      'reservationWarningsMin': reservationWarningsMin,
      'useWarningsMin': useWarningsMin,
      'overstayIntervalMin': overstayIntervalMin,
    };
  }

  factory AppParams.fromJson(Map<String, dynamic> json) {
    return AppParams(
      reservationWindowMin: json['reservationWindowMin'] as int,
      maxUseMin: json['maxUseMin'] as int,
      reservationWarningsMin:
          (json['reservationWarningsMin'] as List<dynamic>).cast<int>(),
      useWarningsMin: (json['useWarningsMin'] as List<dynamic>).cast<int>(),
      overstayIntervalMin: json['overstayIntervalMin'] as int,
    );
  }
}
