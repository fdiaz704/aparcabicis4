import '../../models/reservation.dart';
import '../reservations_repository.dart';
import 'fake_backend.dart';

/// Reservas contra el backend simulado, con la máquina de estados de specs/03.
class FakeReservationsRepository implements ReservationsRepository {
  FakeReservationsRepository(this._backend);

  final FakeBackend _backend;

  @override
  Future<Reservation> createReservation(String parkingId) async {
    await _backend.load();
    return _backend.createReservation(parkingId);
  }

  @override
  Future<Reservation?> getCurrentReservation() async {
    await _backend.load();
    return _backend.fetchCurrentReservation();
  }

  @override
  Future<Reservation> cancelReservation(String reservationId) async {
    await _backend.load();
    return _backend.cancelReservation(reservationId);
  }

  @override
  Future<Reservation> checkout(String reservationId) async {
    await _backend.load();
    return _backend.checkout(reservationId);
  }

  @override
  Future<List<Reservation>> getHistory() async {
    await _backend.load();
    return _backend.fetchHistory();
  }
}
