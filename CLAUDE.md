# CLAUDE.md — Aparcabicis4

Guía para agentes que trabajen en este repositorio. Contiene lo no obvio; el resto se deduce del código.

## Qué es

App **Flutter** (Dart) para reservar plazas en aparcamientos cerrados e inteligentes para bicicletas / VMP.
Cliente R3 RECYMED SL. Solo en español (`es_ES`). UI adaptativa: `CupertinoApp` en iOS, `MaterialApp` en el resto.

## ⚠️ Estructura del repositorio (importante)

- **La app Flutter ES la raíz del repo git:** `C:\Users\fdiaz\AndroidStudioProjects\aparcabicis4` (aquí están `pubspec.yaml`, `lib/`, `android/`, `ios/`, este archivo).
- La subcarpeta `aparcabicis4/aparcabicis4/` es un **proyecto Xcode/SwiftUI suelto de plantilla** (`ContentView.swift`, `aparcabicis4App.swift`). **No forma parte de la app** y no debe tocarse para tareas de la app. Ojo: Android Studio / algunas sesiones abren el cwd ahí dentro.
- Trabaja siempre sobre `lib/` en la raíz Flutter, usando rutas absolutas si tu cwd es la subcarpeta Xcode.

## Comandos

```bash
flutter pub get        # instalar dependencias
flutter run            # ejecutar en dispositivo/emulador
flutter analyze        # lint (reglas en analysis_options.yaml, flutter_lints)
flutter test           # tests (solo existe test/widget_test.dart)
flutter build apk|ios  # build release
```

## Arquitectura

- **Estado:** `provider` con 3 `ChangeNotifierProvider` registrados en [lib/main.dart](lib/main.dart):
  - `AuthProvider` — login/registro/cambio/borrado de cuenta y "Recuérdame".
  - `StationsProvider` — lista de estaciones, favoritos, filtros y orden.
  - `ReservationsProvider` — reserva activa, temporizadores e historial.
- **Navegación:** rutas con nombre + `NavigationService.navigatorKey` global ([lib/services/navigation_service.dart](lib/services/navigation_service.dart)). Nombres de ruta en `AppRoutes` ([lib/utils/constants.dart](lib/utils/constants.dart)).
- **Persistencia:** `shared_preferences` vía `StorageService`. **No hay backend ni base de datos.**
- **Modelos:** `User` (solo email), `BikeStation`, `ReservationRecord` (con `toJson`/`fromJson`).
- **Constantes/tema:** todo centralizado en [lib/utils/constants.dart](lib/utils/constants.dart) (`AppConstants`, `AppColors`, `AppRoutes`, `AppSpacing`…). Color primario `#7AB782`.
- **Utilidades de plataforma:** `lib/utils/platform_*.dart` (iconos, haptics, animaciones, scrolling) abstraen diferencias iOS/Material.

## Estado real vs. especificación

La spec funcional está en `docs/Documentación app aparcabicis.docx` (incluye capturas; las secciones "APIs y Endpoints" son solo títulos, sin definiciones reales). **No darla por implementada.** Estado actual:

- **Todo el backend es simulación local.** `AuthProvider` acepta cualquier login (email no vacío + password ≥8) y los métodos de cuenta devuelven `success:true` tras un `Future.delayed`. Buscar los `// TODO: Replace with actual ... logic`.
- Estaciones **hardcodeadas** (mock) en `StationsProvider._loadMockStations()`.
- Reservas, temporizadores (30 min reserva / 14 h uso) y "Abrir puerta" son lógica local; no hay hardware/API real.
- Sin notificaciones push, sin 2FA, sin tokens de sesión, sin emails reales. El toggle de modo oscuro y el de notificaciones en Ajustes son estado local sin efecto (la app usa `ThemeMode.system`).
- `geolocator` y `permission_handler` están en `pubspec.yaml` pero **no se usan** en `lib/`; la posición del usuario en el mapa la resuelve el propio widget de Google Maps (`myLocationEnabled`).
- En `main.dart` las rutas `/history`, `/profile`, `/settings` apuntan a `Placeholder()`, pero las pantallas reales sí existen y se usan vía tabs en `MainScreen` (rutas muertas).

## Seguridad (deuda conocida — corregir antes de producción)

- **API key de Google Maps hardcodeada y commiteada** (misma clave en `android/app/src/main/AndroidManifest.xml` y `ios/Runner/AppDelegate.swift`). Rotar y restringir por bundle.
- La contraseña se guarda **en claro** en SharedPreferences (`bikeParking_password`).
- La validación de contraseña solo exige letra+número; la spec pide mayúscula + número + carácter especial.

## Convenciones

- Mensajes de usuario y comentarios de dominio en **español**.
- Claves de SharedPreferences con prefijo `bikeParking_` (definidas en `AppConstants`).
- Estilos/medidas/colores siempre desde `constants.dart`, no valores mágicos inline.
- `lib/prueba.md` es un volcado de prototipo (con snippets JS); no es código de la app.
