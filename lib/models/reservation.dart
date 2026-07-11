/// Estados de una reserva. Máquina de estados impuesta por el backend
/// (specs/03-MODELO-DATOS.md): pending → active → completed | cancelled | expired.
enum ReservationStatus {
  /// Reservada, a la espera del check-in (primer "abrir puerta").
  pending,

  /// En uso: el usuario ha hecho check-in y la plaza está ocupada.
  active,

  /// Uso finalizado con checkout confirmado.
  completed,

  /// Cancelada por el usuario antes del check-in.
  cancelled,

  /// Vencida: se agotó la ventana de llegada sin check-in.
  expired,
}

/// Reserva tal y como la sirve la API (specs/04-API.md).
///
/// El backend es la fuente de verdad de estados y tiempos: la app solo pinta
/// cuentas atrás contra [expiresAt] y [maxUntil].
class Reservation {
  final String id;
  final String parkingId;
  final String parkingName;

  /// Dirección del aparcamiento. El contrato de 04-API no la incluye en la
  /// respuesta de reserva; la resolvemos en el cliente (o la sirve el fake)
  /// porque el historial la muestra. Nullable a propósito.
  final String? parkingAddress;

  final ReservationStatus status;

  /// Momento de creación de la reserva.
  final DateTime createdAt;

  /// Vencimiento de la ventana de llegada (createdAt + reservationWindowMin).
  final DateTime expiresAt;

  /// Primer "abrir puerta" exitoso (check-in). Null mientras está `pending`.
  final DateTime? checkinAt;

  /// Límite de uso (checkinAt + maxUseMin). Null mientras está `pending`.
  final DateTime? maxUntil;

  /// Momento del checkout confirmado.
  final DateTime? checkoutAt;

  /// Preparado para tarifas futuras; siempre 0 en v1.
  final int priceCents;
  final String currency;

  const Reservation({
    required this.id,
    required this.parkingId,
    required this.parkingName,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.parkingAddress,
    this.checkinAt,
    this.maxUntil,
    this.checkoutAt,
    this.priceCents = 0,
    this.currency = 'EUR',
  });

  /// La reserva está en curso (ocupa al usuario y bloquea nuevas reservas).
  bool get isOngoing =>
      status == ReservationStatus.pending || status == ReservationStatus.active;

  /// Inicio mostrado en el historial.
  DateTime get startTime => createdAt;

  /// Fin mostrado en el historial (null si no ha finalizado).
  DateTime? get endTime => checkoutAt;

  /// Duración en minutos del uso (o de la vida de la reserva si no hubo uso).
  int get durationMinutes {
    final start = checkinAt ?? createdAt;
    final end = checkoutAt;
    if (end == null) return 0;
    return end.difference(start).inMinutes;
  }

  /// Coste en euros (0 en v1).
  double get cost => priceCents / 100;

  Reservation copyWith({
    String? id,
    String? parkingId,
    String? parkingName,
    String? parkingAddress,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? checkinAt,
    DateTime? maxUntil,
    DateTime? checkoutAt,
    int? priceCents,
    String? currency,
  }) {
    return Reservation(
      id: id ?? this.id,
      parkingId: parkingId ?? this.parkingId,
      parkingName: parkingName ?? this.parkingName,
      parkingAddress: parkingAddress ?? this.parkingAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      checkinAt: checkinAt ?? this.checkinAt,
      maxUntil: maxUntil ?? this.maxUntil,
      checkoutAt: checkoutAt ?? this.checkoutAt,
      priceCents: priceCents ?? this.priceCents,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parkingId': parkingId,
      'parkingName': parkingName,
      'parkingAddress': parkingAddress,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'checkinAt': checkinAt?.toIso8601String(),
      'maxUntil': maxUntil?.toIso8601String(),
      'checkoutAt': checkoutAt?.toIso8601String(),
      'priceCents': priceCents,
      'currency': currency,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      parkingId: json['parkingId'] as String,
      parkingName: json['parkingName'] as String,
      parkingAddress: json['parkingAddress'] as String?,
      status: ReservationStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      checkinAt: json['checkinAt'] == null
          ? null
          : DateTime.parse(json['checkinAt'] as String),
      maxUntil: json['maxUntil'] == null
          ? null
          : DateTime.parse(json['maxUntil'] as String),
      checkoutAt: json['checkoutAt'] == null
          ? null
          : DateTime.parse(json['checkoutAt'] as String),
      priceCents: (json['priceCents'] as int?) ?? 0,
      currency: (json['currency'] as String?) ?? 'EUR',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Reservation && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
