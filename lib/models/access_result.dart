/// Resultado de `POST /reservations/{id}/open` (RF-4.2).
///
/// El backend ordena la apertura a la pasarela hardware y responde en <5 s.
enum AccessStatus {
  /// La puerta se abrió correctamente.
  opened,

  /// La pasarela respondió pero no pudo abrir.
  failed,

  /// La pasarela no respondió a tiempo (modo degradado, RF-4.7).
  timeout,
}

/// Respuesta de una orden de apertura de puerta.
class AccessResult {
  final AccessStatus status;

  /// Puerta accionada (informativo).
  final String? doorId;

  const AccessResult({required this.status, this.doorId});

  bool get isOpened => status == AccessStatus.opened;

  /// La pasarela no respondió: la UI debe ofrecer el teléfono de soporte
  /// (modo degradado, RF-4.7).
  bool get isDegraded => status == AccessStatus.timeout;

  Map<String, dynamic> toJson() => {'status': status.name, 'doorId': doorId};

  factory AccessResult.fromJson(Map<String, dynamic> json) {
    return AccessResult(
      status: AccessStatus.values.byName(json['status'] as String),
      doorId: json['doorId'] as String?,
    );
  }
}
