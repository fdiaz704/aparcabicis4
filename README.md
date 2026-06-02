# Aparcabicis

Aplicación móvil **Flutter** para reservar y gestionar plazas en aparcamientos cerrados e
inteligentes para bicicletas y Vehículos de Movilidad Personal (VMP).

Permite localizar aparcamientos en un mapa o en lista, consultar disponibilidad, reservar una
plaza durante un tiempo limitado, "abrir la puerta" para iniciar el uso y consultar el historial
y las estadísticas de uso. La interfaz es adaptativa (estilo Cupertino en iOS y Material en el
resto de plataformas) y está íntegramente en español.

> **Estado actual:** la app funciona de forma autónoma con **datos simulados en local**. No hay
> backend, base de datos ni API remota: la autenticación acepta cualquier credencial válida, las
> estaciones están embebidas en el código y la persistencia se hace con `SharedPreferences`.
> Los puntos pendientes de integración están marcados con `// TODO` en el código (ver
> `lib/providers/auth_provider.dart`).

## Requisitos

- **Flutter SDK** con Dart `^3.9.2` (canal stable reciente).
- **Android:** Android Studio + SDK; dispositivo/emulador con Android 6.0 (API 23) o superior.
- **iOS** (solo desde macOS): Xcode + CocoaPods; dispositivo/simulador con iOS 13.0 o superior.
- **Clave de Google Maps** para que el mapa cargue (ver más abajo).

Comprueba tu entorno con:

```bash
flutter doctor
```

## Estructura del repositorio

> ⚠️ La app Flutter es la **raíz de este repositorio** (donde está este README y `pubspec.yaml`).
> La subcarpeta `aparcabicis4/aparcabicis4/` es un proyecto Xcode/SwiftUI de plantilla, **ajeno a
> la app**, y puede ignorarse. Ejecuta todos los comandos desde la raíz del repo.

## Instalación

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd aparcabicis4

# 2. Instalar dependencias
flutter pub get

# 3. (Solo iOS / macOS) instalar pods
cd ios && pod install && cd ..
```

### Configurar Google Maps (API key)

El mapa de estaciones usa `google_maps_flutter` y necesita una API key de Google Maps. La clave
**no se commitea**: se inyecta en build-time desde ficheros de secrets ignorados por git. Hay una
plantilla `*.example` por plataforma; cópiala y pega tu clave.

**Android** — copia la plantilla y rellena la clave:

```bash
cp android/secrets.properties.example android/secrets.properties
# edita android/secrets.properties:  MAPS_API_KEY=TU_API_KEY
```

`android/app/build.gradle.kts` lee ese fichero y lo inyecta en `AndroidManifest.xml` mediante
`manifestPlaceholders` (`${MAPS_API_KEY}`).

**iOS** — copia la plantilla y rellena la clave:

```bash
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
# edita ios/Flutter/Secrets.xcconfig:  MAPS_API_KEY = TU_API_KEY
```

`Debug.xcconfig`/`Release.xcconfig` incluyen `Secrets.xcconfig`, `Info.plist` expone la clave como
`MapsApiKey` y `AppDelegate.swift` la lee en arranque (`GMSServices.provideAPIKey`).

**CI** — en vez de los ficheros de secrets puedes:

- Android: exportar la variable de entorno `MAPS_API_KEY` (el `build.gradle.kts` la usa como fallback).
- iOS: generar `ios/Flutter/Secrets.xcconfig` desde un secreto del pipeline antes de compilar.

> ⚠️ Sin clave, el build **no falla** pero el mapa no se renderiza. **Restringe la clave por
> bundle/app** en Google Cloud antes de publicar. Si una clave se filtra, **rótala**: una vez
> commiteada queda en el historial de git para siempre.

## Cómo arrancar en desarrollo

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en el dispositivo/emulador por defecto (modo debug, con hot reload)
flutter run

# Ejecutar en un dispositivo concreto
flutter run -d <device-id>
```

Durante `flutter run`, pulsa `r` para *hot reload* y `R` para *hot restart*.

Otros comandos útiles:

```bash
flutter analyze          # análisis estático / lint (reglas en analysis_options.yaml)
flutter test             # ejecutar tests (test/widget_test.dart)
flutter build apk        # build de release para Android
flutter build ios        # build de release para iOS (requiere macOS)
```

### Notas para desarrollo

- **Login:** al no haber backend, sirve cualquier email con formato válido y una contraseña de
  8+ caracteres (con al menos una letra y un número). "Recuérdame" recuerda **solo el email** (la
  contraseña no se rellena automáticamente).
- **Estaciones:** son datos mock definidos en `StationsProvider._loadMockStations()`.
- **Permisos de ubicación:** declarados en `AndroidManifest.xml` (`ACCESS_FINE/COARSE_LOCATION`) e
  `Info.plist` (`NSLocationWhenInUseUsageDescription`). La posición del usuario en el mapa la
  gestiona el propio widget de Google Maps (`myLocationEnabled`).

## Seguridad

- **Secrets fuera del código:** las API keys se inyectan desde ficheros gitignored (ver
  *Configurar Google Maps*). No hay claves hardcodeadas en el código.
- **La contraseña nunca se persiste en el dispositivo.** "Recuérdame" guarda solo el email en
  `SharedPreferences`. Las instalaciones antiguas que tuvieran la contraseña en claro se limpian
  automáticamente al arrancar (`AuthProvider._migrateLegacyCredentials`).
- **Almacenamiento seguro de tokens:** `lib/services/secure_storage_service.dart` envuelve
  `flutter_secure_storage` (Keychain en iOS / Keystore en Android) para el **token de sesión**.
  Cuando exista backend real, `login` debe guardar **solo el token** devuelto (nunca la
  contraseña); `logout` ya lo borra. Los puntos de enganche están marcados con `// TODO` en
  `AuthProvider`.

## Estructura del proyecto

```
lib/
├── main.dart                       # Punto de entrada; configura providers, tema y rutas
├── models/                         # Modelos de datos (con toJson / fromJson)
│   ├── bike_station.dart           #   Estación: id, nombre, dirección, plazas, lat/lng
│   ├── reservation_record.dart     #   Registro de reserva: tiempos, duración, estado, coste
│   └── user.dart                   #   Usuario (solo email)
├── providers/                      # Estado de la app (provider / ChangeNotifier)
│   ├── auth_provider.dart          #   Login, registro, cambio/borrado de cuenta, "Recuérdame"
│   ├── stations_provider.dart      #   Estaciones, favoritos, filtros y orden
│   └── reservations_provider.dart  #   Reserva activa, temporizadores e historial
├── screens/
│   ├── splash_screen.dart          #   Pantalla inicial / comprobación de sesión
│   ├── login/                      #   Login, crear/eliminar usuario, cambiar/recuperar contraseña
│   └── main/                       #   Principal (tabs), lista, mapa, reserva activa,
│                                   #   historial, perfil, ajustes, ayuda
├── services/
│   ├── navigation_service.dart     #   navigatorKey global y helpers de navegación
│   └── storage_service.dart        #   Wrapper sobre SharedPreferences
├── utils/
│   ├── constants.dart              #   AppConstants, AppColors, AppRoutes, estilos, dimensiones
│   ├── adaptive_theme.dart         #   Temas Material / Cupertino
│   └── platform_*.dart             #   Utilidades específicas de plataforma (iconos, haptics…)
└── widgets/                        # Componentes reutilizables
    ├── bike_station_card.dart
    ├── history_card.dart
    └── stat_card.dart
```

Otras carpetas: `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` (proyectos de
plataforma generados por Flutter), `assets/` (imágenes, iconos y recursos) y `test/`.

## Dependencias

Definidas en [`pubspec.yaml`](pubspec.yaml):

| Paquete                 | Uso                                                      |
| ----------------------- | -------------------------------------------------------- |
| `provider`              | Gestión de estado (ChangeNotifier)                       |
| `shared_preferences`    | Persistencia local clave-valor (no sensible)             |
| `flutter_secure_storage`| Almacenamiento seguro (Keychain/Keystore) del token de sesión |
| `google_maps_flutter`   | Mapa interactivo con marcadores de estaciones            |
| `geolocator`            | Geolocalización (en dependencias; sin uso directo en `lib/`) |
| `permission_handler`    | Gestión de permisos del sistema                          |
| `url_launcher`          | Abrir enlaces externos / llamadas de teléfono (soporte)  |
| `intl`                  | Formato de fechas y números                              |
| `flutter_localizations` | Localización (configurada para `es_ES`)                  |
| `lucide_flutter`        | Set de iconos                                            |
| `cupertino_icons`       | Iconos estilo iOS                                        |

**Dev:** `flutter_test`, `flutter_lints`.

## Plataformas soportadas

Android, iOS, Web, macOS, Windows y Linux (configuración de Flutter generada). El desarrollo y las
funcionalidades nativas (mapas, ubicación) están orientados principalmente a **Android e iOS**.
