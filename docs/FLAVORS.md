# Flavors multi-ciudad (RF-0)

La app se compila **un binario por ciudad**. La ciudad activa se selecciona en
compilación y toda la configuración dependiente de ciudad vive en
`lib/config/` (ninguna clase fuera de ahí conoce una ciudad concreta).

## Piezas

- `lib/config/city_config.dart` — clase `CityConfig` (nombre, `apiBaseUrl`,
  centro/zoom del mapa, branding, IDs de tienda, URLs legales, idiomas y
  aparcamientos semilla).
- `lib/config/cities/<slug>.dart` — una `CityConfig` por ciudad. Hoy: `demo`
  (semilla con los 8 aparcamientos de Madrid).
- `lib/config/app_flavor.dart` — `resolveCityConfig()` lee
  `--dart-define=CITY=<slug>` (por defecto `demo`) y devuelve la config.

## Compilar / ejecutar

```bash
# Dev (repos fake, sin backend) para la ciudad demo
flutter run --flavor demo --dart-define=CITY=demo

# Build release Android de la ciudad demo
flutter build apk --flavor demo --dart-define=CITY=demo
```

El slug de `--dart-define=CITY` debe coincidir con el flavor y con una entrada
del registro en `app_flavor.dart`; si no, la app lanza `StateError` al arrancar.

## Android

`android/app/build.gradle.kts` define la dimensión `city` y el flavor `demo`
con `applicationIdSuffix = ".demo"` (applicationId propio por ciudad, RF-0.4).
El nombre visible sale de `@string/app_name`, aportado por cada flavor con
`resValue`. Para añadir una ciudad: nuevo `productFlavor` + nuevo fichero en
`lib/config/cities/` + entrada en el registro de `app_flavor.dart`.

## iOS — PENDIENTE (requiere macOS/Xcode)

La creación de **schemes** de iOS por ciudad (build configurations
`Debug-<slug>`/`Release-<slug>` + scheme + bundleId propio) debe hacerse en
Xcode y **no puede completarse desde este entorno Linux**. Queda como tarea
manual pendiente. El mecanismo `--dart-define=CITY=` ya funciona en iOS; solo
falta el scheme/bundleId por ciudad en el proyecto Xcode.
