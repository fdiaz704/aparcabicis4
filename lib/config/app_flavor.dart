import 'city_config.dart';
import 'cities/demo.dart';

/// Slug de la ciudad seleccionada en compilación mediante
/// `--dart-define=CITY=<slug>`. Por defecto `demo`.
const String kCitySlug = String.fromEnvironment('CITY', defaultValue: 'demo');

/// Registro de ciudades disponibles (una por flavor). Añadir aquí cada nueva
/// ciudad junto con su fichero en `lib/config/cities/`.
const Map<String, CityConfig> _cities = {
  'demo': demoCity,
};

/// Devuelve la configuración de la ciudad activa según el flavor compilado.
///
/// Lanza [StateError] si el slug de `--dart-define=CITY=` no está registrado,
/// para fallar de forma temprana y explícita ante un flavor mal configurado.
CityConfig resolveCityConfig() {
  final config = _cities[kCitySlug];
  if (config == null) {
    throw StateError(
      'Ciudad desconocida en --dart-define=CITY=$kCitySlug. '
      'Ciudades disponibles: ${_cities.keys.join(', ')}.',
    );
  }
  return config;
}
