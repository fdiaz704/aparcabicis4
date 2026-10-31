import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado de pedir la ubicación del usuario (RF-2.4).
enum LocationStatus {
  /// Permiso concedido y posición obtenida.
  granted,

  /// El usuario denegó el permiso (puede volver a pedirse).
  denied,

  /// Denegado permanentemente: hay que ir a los ajustes del sistema.
  deniedForever,

  /// La ubicación del dispositivo está desactivada.
  serviceDisabled,

  /// Error al obtener la posición (sin señal, timeout…).
  unavailable,
}

/// Posición del usuario.
class UserLocation {
  const UserLocation({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// Resultado de [LocationService.getCurrentLocation].
class LocationResult {
  const LocationResult(this.status, [this.location]);

  final LocationStatus status;
  final UserLocation? location;

  bool get isGranted => status == LocationStatus.granted && location != null;
}

/// Ubicación del usuario. Tras una interfaz para poder falsearla en tests
/// (el emulador/entorno de test no tiene GPS).
abstract interface class LocationService {
  /// Pide permiso si hace falta y devuelve la posición actual.
  Future<LocationResult> getCurrentLocation();

  /// Distancia en metros entre dos puntos.
  double distanceMeters(double lat1, double lng1, double lat2, double lng2);
}

/// Implementación real sobre `geolocator`.
class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(LocationStatus.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(LocationStatus.deniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(LocationStatus.denied);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        LocationStatus.granted,
        UserLocation(lat: position.latitude, lng: position.longitude),
      );
    } catch (e) {
      debugPrint('Error obteniendo la ubicación: $e');
      return const LocationResult(LocationStatus.unavailable);
    }
  }

  @override
  double distanceMeters(double lat1, double lng1, double lat2, double lng2) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
}
