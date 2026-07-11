import '../../models/parking.dart';
import '../parkings_repository.dart';
import 'fake_backend.dart';

/// Aparcamientos servidos desde la semilla del flavor (CityConfig), sin red.
class FakeParkingsRepository implements ParkingsRepository {
  FakeParkingsRepository(this._backend);

  final FakeBackend _backend;

  @override
  Future<List<Parking>> getParkings() async {
    await _backend.load();
    return _backend.fetchParkings();
  }

  @override
  Future<Parking?> getParking(String parkingId) async {
    await _backend.load();
    return _backend.findParking(parkingId);
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    await _backend.load();
    return _backend.favoriteIds.toList();
  }

  @override
  Future<void> setFavorite(String parkingId, {required bool favorite}) async {
    await _backend.load();
    await _backend.setFavorite(parkingId, favorite: favorite);
  }
}
