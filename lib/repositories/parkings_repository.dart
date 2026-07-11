import '../models/parking.dart';

/// Acceso a los aparcamientos de la ciudad del flavor (specs/04-API.md).
abstract interface class ParkingsRepository {
  /// `GET /parkings?city=<slug>`: aparcamientos de la ciudad activa.
  Future<List<Parking>> getParkings();

  /// `GET /parkings/{id}`: ficha de un aparcamiento, o null si no existe.
  Future<Parking?> getParking(String parkingId);

  /// `GET /me/favorites`: IDs de los aparcamientos marcados como favoritos.
  Future<List<String>> getFavoriteIds();

  /// `PUT`/`DELETE /parkings/{id}/favorite`.
  Future<void> setFavorite(String parkingId, {required bool favorite});
}
