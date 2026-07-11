import 'package:flutter/widgets.dart';

import '../models/parking.dart';

/// Identidad visual por ciudad (flavor).
class CityBranding {
  /// Color primario de la marca de la ciudad.
  final Color primaryColor;

  /// Ruta del logo en assets para esta ciudad.
  final String logoAsset;

  const CityBranding({
    required this.primaryColor,
    required this.logoAsset,
  });
}

/// Identificadores de tienda por ciudad (para la comprobación de versión y
/// los enlaces "Actualizar" de RF-A).
class CityStoreIds {
  /// applicationId publicado en Google Play.
  final String androidPackageId;

  /// Identificador numérico de la app en App Store.
  final String iosAppStoreId;

  const CityStoreIds({
    required this.androidPackageId,
    required this.iosAppStoreId,
  });
}

/// Configuración específica de una ciudad (flavor).
///
/// Es la ÚNICA fuente de datos dependientes de ciudad. Por diseño (RF-0), fuera
/// de `lib/config/` ninguna clase debe conocer una ciudad concreta: todo lo
/// dependiente de ciudad (nombre, coordenadas del mapa, URL de API, branding,
/// IDs de tienda, textos legales, idiomas) llega a través de este objeto
/// inyectado.
class CityConfig {
  /// Slug de la ciudad; coincide con el flavor y con `--dart-define=CITY=`.
  final String cityId;

  /// Nombre mostrado (p. ej. en "Acerca de").
  final String name;

  /// URL base de la API REST para esta ciudad.
  final String apiBaseUrl;

  /// Centro por defecto del mapa.
  final double mapCenterLat;
  final double mapCenterLng;

  /// Nivel de zoom inicial del mapa.
  final double mapZoom;

  /// Identidad visual.
  final CityBranding branding;

  /// Identificadores de tienda.
  final CityStoreIds storeIds;

  /// URL de términos y condiciones.
  final String termsUrl;

  /// URL de política de privacidad.
  final String privacyUrl;

  /// Idiomas soportados por la ciudad (RF-0.2).
  final List<Locale> supportedLocales;

  /// Aparcamientos semilla para desarrollo/pruebas sin backend. En producción
  /// se sustituyen por los servidos por la API (fase 4). Vacío por defecto.
  final List<Parking> seedParkings;

  const CityConfig({
    required this.cityId,
    required this.name,
    required this.apiBaseUrl,
    required this.mapCenterLat,
    required this.mapCenterLng,
    this.mapZoom = 13,
    required this.branding,
    required this.storeIds,
    required this.termsUrl,
    required this.privacyUrl,
    required this.supportedLocales,
    this.seedParkings = const [],
  });
}
