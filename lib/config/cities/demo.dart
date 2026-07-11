import 'package:flutter/widgets.dart';

import '../../models/parking.dart';
import '../city_config.dart';

/// Ciudad de demostración.
///
/// Flavor por defecto para desarrollo y pruebas. Contiene como semilla los 8
/// aparcamientos de Madrid que antes estaban hardcodeados en `ParkingsProvider`
/// (RF-0.3). No representa un despliegue comercial real.
const CityConfig demoCity = CityConfig(
  cityId: 'demo',
  name: 'Demo',
  apiBaseUrl: 'https://api.aparcabicis4.example/v1',
  mapCenterLat: 40.4168, // Puerta del Sol
  mapCenterLng: -3.7038,
  branding: CityBranding(
    primaryColor: Color(0xFF7AB782),
    logoAsset: 'assets/logo.png',
  ),
  storeIds: CityStoreIds(
    androidPackageId: 'com.r3recymed.aparcabicis.demo',
    iosAppStoreId: '0000000000',
  ),
  termsUrl: 'https://aparcabicis4.example/demo/terminos',
  privacyUrl: 'https://aparcabicis4.example/demo/privacidad',
  supportedLocales: [Locale('es'), Locale('ca')],
  seedParkings: _demoSeedParkings,
);

/// Semilla de aparcamientos de la ciudad demo (antiguos mocks de Madrid).
const List<Parking> _demoSeedParkings = [
  Parking(
    id: '1',
    name: 'Plaza Mayor',
    address: 'Calle Mayor, 1',
    availableSpots: 3,
    totalSpots: 10,
    lat: 40.4155,
    lng: -3.7074,
  ),
  Parking(
    id: '2',
    name: 'Aparcamiento Atocha',
    address: 'Plaza del Emperador Carlos V',
    availableSpots: 5,
    totalSpots: 15,
    lat: 40.4064,
    lng: -3.6910,
  ),
  Parking(
    id: '3',
    name: 'Retiro Park',
    address: 'Paseo del Prado, 8',
    availableSpots: 0,
    totalSpots: 8,
    lat: 40.4152,
    lng: -3.6844,
  ),
  Parking(
    id: '4',
    name: 'Gran Vía Centro',
    address: 'Gran Vía, 32',
    availableSpots: 2,
    totalSpots: 12,
    lat: 40.4200,
    lng: -3.7038,
  ),
  Parking(
    id: '5',
    name: 'Malasaña',
    address: 'Calle Fuencarral, 45',
    availableSpots: 7,
    totalSpots: 10,
    lat: 40.4267,
    lng: -3.7038,
  ),
  Parking(
    id: '6',
    name: 'Chueca',
    address: 'Plaza de Chueca, 3',
    availableSpots: 1,
    totalSpots: 6,
    lat: 40.4239,
    lng: -3.6968,
  ),
  Parking(
    id: '7',
    name: 'Sol',
    address: 'Puerta del Sol, 1',
    availableSpots: 4,
    totalSpots: 20,
    lat: 40.4168,
    lng: -3.7038,
  ),
  Parking(
    id: '8',
    name: 'Tribunal',
    address: 'Calle Tribunal, 15',
    availableSpots: 6,
    totalSpots: 10,
    lat: 40.4267,
    lng: -3.7008,
  ),
];
