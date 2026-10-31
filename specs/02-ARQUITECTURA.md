# 02 — Arquitectura

## 1. Visión general

```
┌─────────────── App Flutter (evolución Aparcabicis4) ───────────────┐
│  Screens (UI actual reutilizada)                                   │
│    └── Providers (Auth, Parkings, Reservations, Settings)          │
│          └── Repositorios (INTERFACES)                             │
│                ├── FakeRepository   (dev/tests, sin red)           │
│                └── ApiRepository    (Dio/http → API REST)          │
│  Servicios: SecureStorage · StorageService · Navigation · Location │
└─────────────────────────────────────────────────────────────────────┘
                    │ HTTPS + JWT
┌─────────────────── Backend propio (API REST) ──────────────────────┐
│  Auth (JWT) · Parkings · Reservations · Access · Users             │
│  MariaDB                                                           │
│  Gateway de acceso ── MQTT / API fabricante ──► Hardware puertas   │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. App Flutter — qué se conserva y qué cambia

### Se conserva
- Estructura de pantallas y navegación (NavigationService, rutas con nombre).
- Provider como gestión de estado.
- Capa adaptativa iOS/Android (`platform_*`, AdaptiveTheme).
- Pantallas de mapa, lista, reserva activa, historial, perfil, ajustes.

### Cambia
| Actual | Nuevo |
|---|---|
| `BikeStation` estático | `Parking` servido por API (renombrar modelo y pantallas) |
| `AuthProvider` mock | `AuthProvider` → `AuthRepository` → API (JWT) |
| Credenciales en SharedPreferences (texto plano) | Tokens en `flutter_secure_storage`; SharedPreferences solo para preferencias no sensibles |
| Historial local | Historial remoto con caché local |
| Timers como fuente de verdad | Backend fuente de verdad; timers solo cuenta atrás visual sincronizada con `expiresAt` |
| Providers llaman a SharedPreferences directamente | Todo acceso a datos pasa por repositorios; `StorageService` único punto de persistencia local |

### Nuevas dependencias Flutter
`dio` (HTTP + interceptores JWT), `flutter_secure_storage`, `local_auth` (biometría), `flutter_local_notifications` (avisos de reserva/uso), `package_info_plus` + `upgrader` (comprobación de versión de tiendas), `mocktail` (tests). Ya presentes y por fin usadas: `geolocator`, `permission_handler`, `intl`/ARB para i18n `es`/`ca` (valencià).

### Multi-ciudad (flavors)
- Compilación: `--dart-define=CITY=<slug>` + productFlavors (Android) / schemes (iOS) con applicationId/bundleId por ciudad.
- `lib/config/cities/<slug>.dart` implementa `CityConfig`: cityId, nombre, apiBaseUrl, centro/zoom de mapa, branding, storeIds, URLs de términos/privacidad.
- Regla: ninguna clase fuera de `config/` conoce la ciudad; todo llega por `CityConfig` inyectado.

### Estructura de carpetas objetivo (lib/)
```
lib/
├── config/            # entornos (dev/prod) + cities/<slug>.dart (CityConfig)
├── l10n/              # ARB: app_es.arb, app_ca.arb (valencià)
├── models/            # parking.dart, reservation.dart, user.dart, bootstrap.dart
├── repositories/      # *_repository.dart (abstract) + fake/ + api/
├── services/          # api_client, secure_storage, storage, navigation, location,
│                      # biometric_service, local_notifications_service,
│                      # version_check_service, route_service (ETA estimado)
├── providers/         # auth, parkings, reservations, settings, session (bootstrap)
├── screens/           # (estructura actual, renombrada estación→parking)
├── widgets/           # markers personalizados, tarjetas, etc.
└── utils/
```

### Servicios transversales nuevos
- **VersionCheckService** (splash): consulta `POST /check_version` con `{platform, version_code, build_number}` del binario instalado (package_info_plus). Respuesta `{latest_version, latest_build, force_update, url, client_known}`: si `force_update=true` ⇒ pantalla **bloqueante** no descartable con botón "Actualizar" (abre `url`); si `latest_build > build instalado` (sin forzar) ⇒ **aviso descartable**. `upgrader` puede seguir usándose como señal complementaria de tienda.
- **BiometricService**: alta al activar "Recuérdame"; restaura sesión con biometría; fallback a contraseña.
- **LocalNotificationsService**: programa series contra `expiresAt` (T−10', T−5', T) y `maxUntil` (T−30', T−15', T−5', luego cada 30'); se reprograma en cada sync con la API y se cancela en checkout/cancelación.
- **RouteService**: ETA **estimado en el cliente** (haversine × factor de rodeo, a velocidad media de bici); compara el ETA con la ventana de reserva restante y avisa. Sin Directions API: descartada por coste y por no poder proteger la clave dentro del APK. Si más adelante el backend sirve la ruta real (polyline), basta cambiar la implementación tras la interfaz.

## 3. Backend propio — alcance de la spec

El contrato manda (04-API.md): cualquier stack que lo cumpla vale. **Elegido:** **PHP 8 + MySQL/MariaDB** sobre el hosting **LAMP** existente, con framework **Slim** (o equivalente) y JWT. Sin Docker ni ORM impuesto. El job de expiración de reservas se ejecuta con el **cron del hosting**. Repositorio separado del de la app (`aparcabicis4-api`).

Módulos:
- **auth**: registro, login, refresh, recuperación (email vía SMTP del hosting), borrado de cuenta.
- **parkings**: CRUD (admin) + lectura pública autenticada; ocupación derivada de reservas activas + señal del hardware si existe.
- **reservations**: máquina de estados `pending → active → completed | cancelled | expired`. Job de expiración de reservas vencidas ejecutado por el **cron del hosting** (LAMP).
- **access**: endpoint de apertura; publica comando a la pasarela y espera ACK con timeout de 5 s; audita todo en `access_events`.
- **gateway hardware**: adaptador con interfaz `GateController { open(parkingId, doorId): Result }`. Implementaciones: `MqttGateController` (real) y `SimGateController` (simulador que responde éxito/fallo configurable). *