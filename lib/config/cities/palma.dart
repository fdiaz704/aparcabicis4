import 'package:flutter/widgets.dart';

import '../city_config.dart';

/// Ciudad de Palma (Palma de Mallorca).
///
/// Segundo flavor, que demuestra el mecanismo multi-ciudad (RF-0) con más de
/// una ciudad. Los datos concretos (apiBaseUrl, IDs de tienda, URLs legales)
/// son provisionales hasta disponer de los reales; los aparcamientos no se
/// siembran localmente (vendrán de la API en fase 4), de ahí `seedParkings`
/// vacío.
const CityConfig palmaCity = CityConfig(
  cityId: 'palma',
  name: 'Palma',
  apiBaseUrl: 'https://api.aparcabicis4.example/v1',
  mapCenterLat: 39.5696, // Plaça de Cort, Palma de Mallorca
  mapCenterLng: 2.6502,
  branding: CityBranding(
    primaryColor: Color(0xFF7AB782),
    logoAsset: 'assets/logo.png',
  ),
  storeIds: CityStoreIds(
    androidPackageId: 'com.r3recymed.aparcabicis.palma',
    iosAppStoreId: '0000000000',
  ),
  termsUrl: 'https://aparcabicis4.example/palma/terminos',
  privacyUrl: 'https://aparcabicis4.example/palma/privacidad',
  supportedLocales: [Locale('es'), Locale('ca')],
);
