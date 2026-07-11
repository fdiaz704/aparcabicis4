import '../../models/access_result.dart';
import '../access_repository.dart';
import 'fake_backend.dart';

/// Apertura de puerta simulada (equivale al `SimGateController` del backend).
///
/// Un open exitoso sobre una reserva `pending` provoca el check-in en el
/// backend simulado, igual que hará la API real (RF-4.3).
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository(
    this._backend, {
    this.simulatedStatus = AccessStatus.opened,
  });

  final FakeBackend _backend;

  /// Permite simular la pasarela degradada (`failed`/`timeout`, RF-4.7) en
  /// pruebas sin tocar el resto del flujo.
  final AccessStatus simulatedStatus;

  @override
  Future<AccessResult> openDoor(String reservationId) async {
    await _backend.load();

    if (simulatedStatus != AccessStatus.opened) {
      // La pasarela no abre: el estado de la reserva NO cambia.
      return AccessResult(status: simulatedStatus);
    }

    // Apertura correcta: el backend hace el check-in si procede.
    await _backend.openDoor(reservationId);
    return const AccessResult(status: AccessStatus.opened, doorId: 'door-1');
  }
}
