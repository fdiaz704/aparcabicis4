import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ruta estimada hasta un aparcamiento (RF-2.6).
class RouteInfo {
  const RouteInfo({
    required this.eta,
    required this.distanceMeters,
    this.points = const [],
  });

  /// Puntos del recorrido a pintar sobre el mapa.
  ///
  /// Vacía con la estimación: no se dibuja una polyline que no corresponde a un
  /// recorrido real por calles. Queda preparada para cuando el backend sirva la
  /// ruta (fase 3/4).
  final List<LatLng> points;

  /// Tiempo estimado de llegada en bicicleta.
  final Duration eta;

  /// Distancia estimada del recorrido, en metros.
  final int distanceMeters;
}

/// Cálculo de la ruta y del tiempo de llegada hasta un aparcamiento.
///
/// Tras una interfaz para poder sustituirla sin tocar la UI: hoy se estima en
/// el cliente (sin coste), y más adelante podrá servirla el backend.
abstract interface class RouteService {
  Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
  });
}

/// Estimación local del trayecto, **sin coste ni servicios externos**.
///
/// Se descartó la Google Directions API por su coste (y porque llamarla desde
/// la app obligaría a incrustar en el APK una clave sin restricciones).
///
/// Cálculo: distancia en línea recta (haversine) × [detourFactor], recorrida a
/// [bikeSpeedKmh] de velocidad media.
///
/// **Sobre [detourFactor]:** alimenta el aviso de "puede que no llegues a
/// tiempo" (HU-4), así que conviene **errar por exceso**. Quedarse corto en el
/// ETA es el error peligroso: no se avisaría y el usuario perdería la reserva.
class EstimatedRouteService implements RouteService {
  const EstimatedRouteService({
    this.bikeSpeedKmh = 15,
    this.detourFactor = defaultDetourFactor,
  });

  /// Velocidad media en bici por ciudad.
  final double bikeSpeedKmh;

  /// Factor de rodeo sobre la línea recta: en trama urbana el recorrido real
  /// suele ser un 20-40 % más largo que la recta.
  final double detourFactor;

  static const double defaultDetourFactor = 1.30;

  @override
  Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final straight = _haversineMeters(origin, destination);
    final routeMeters = (straight * detourFactor).round();
    final seconds = routeMeters / (bikeSpeedKmh * 1000 / 3600);

    return RouteInfo(
      eta: Duration(seconds: seconds.round()),
      distanceMeters: routeMeters,
    );
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadius * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  double _rad(double deg) => deg * math.pi / 180;
}
