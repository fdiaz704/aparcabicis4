import '../services/route_service.dart';

/// Servicio de rutas de la app.
///
/// Se estima en el cliente, **sin coste ni servicios externos**: se descartó la
/// Google Directions API por lo que factura. El aviso de "puede que no llegues
/// a tiempo" (HU-4) se calcula con esta estimación, así que funciona siempre,
/// sin red y sin claves.
///
/// Si en el futuro el backend sirve la ruta real (fase 3/4), basta sustituir
/// aquí la implementación: la UI no cambia.
RouteService resolveRouteService() => const EstimatedRouteService();
