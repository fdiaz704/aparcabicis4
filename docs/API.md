# API — Aparcabicis

Documentación del contrato de datos de la aplicación, basada en el **código real** (`lib/`).

## ⚠️ Estado: no hay API HTTP implementada

A día de hoy **el proyecto no realiza ninguna llamada de red**: no hay cliente HTTP, ni `http`/`dio`,
ni Firebase, ni URLs de servidor. Toda la "lógica de negocio" está **simulada en local** dentro de
los providers (`lib/providers/`), normalmente tras un `Future.delayed(...)`, y la persistencia se
hace con `SharedPreferences`. Cada operación que en una arquitectura real sería una llamada a API
está marcada en el código con `// TODO: Replace with actual ... logic`.

Este documento sirve para dos cosas:

1. **Contrato real (implementado):** la firma exacta de cada operación tal y como existe hoy en los
   providers — parámetros, "cuerpo", respuesta y errores. Es lo que hay que respetar al integrar un
   backend sin romper la UI.
2. **Endpoint REST propuesto:** completa la sección 4 ("APIs y Endpoints") del documento funcional
   `Documentación app aparcabicis.docx`, que solo enumera categorías sin definirlas. Las rutas,
   métodos y códigos HTTP marcados como _propuesto_ **no existen todavía** en el código.

### Convenciones del contrato actual

- Las operaciones de cuenta devuelven siempre un mapa `{ "success": bool, "message": String }`
  (en español). No hay códigos de estado HTTP; el éxito/fracaso se comunica con `success`.
- `login` devuelve `bool`. Las operaciones de reserva devuelven `bool` o `void`.
- No hay tokens de sesión, ni cabeceras de autenticación, ni JSON real sobre el cable.
- Almacenamiento local con claves prefijadas `bikeParking_` (definidas en `AppConstants`).

### Modelos de datos

Definidos en `lib/models/` (todos con `toJson` / `fromJson`):

**User** — `lib/models/user.dart`
```json
{ "email": "usuario@dominio.com" }
```

**BikeStation** — `lib/models/bike_station.dart`
```json
{
  "id": "1",
  "name": "Plaza Mayor",
  "address": "Calle Mayor, 1",
  "availableSpots": 3,
  "totalSpots": 10,
  "lat": 40.4155,
  "lng": -3.7074
}
```

**ReservationRecord** — `lib/models/reservation_record.dart`
```json
{
  "id": "1717000000000",
  "stationName": "Plaza Mayor",
  "stationAddress": "Calle Mayor, 1",
  "startTime": "2026-06-01T17:21:00.000",
  "endTime": "2026-06-01T17:51:00.000",
  "duration": 30,
  "status": "completed",
  "cost": 0.0
}
```
`status` ∈ `completed` | `cancelled` | `expired` (enum `ReservationStatus`).

### Reglas de validación (compartidas)

- **Email:** regex `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` (`AuthProvider._isValidEmail`).
- **Contraseña:** mínimo **8 caracteres** y al menos **una letra y un número**
  (`AuthProvider._isStrongPassword`, regex `^(?=.*[A-Za-z])(?=.*\d)`).
  > Nota: el documento funcional pide además mayúscula y carácter especial; el código **no** lo exige.

---

## 4.1. Módulo de Autenticación y Gestión de Usuarios

Implementado en [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.dart).

### 4.1.1. Inicio de sesión

- **Implementado:** `AuthProvider.login(String email, String password, bool rememberMe) → Future<bool>` ([auth_provider.dart:44](../lib/providers/auth_provider.dart))
- **Endpoint propuesto:** `POST /api/auth/login`

**Parámetros / cuerpo**
```json
{ "email": "usuario@dominio.com", "password": "Secreta123", "rememberMe": true }
```

**Respuesta (real)** — `true` si `email` no está vacío **y** `password.length >= 8`; si no, `false`.
Al iniciar sesión correctamente con `rememberMe = true`, guarda email, contraseña (¡en claro!) y
estado de sesión en `SharedPreferences`; con `false`, limpia esas credenciales.

**Respuesta propuesta** — `200 OK`
```json
{ "success": true, "token": "<jwt>", "user": { "email": "usuario@dominio.com" } }
```

**Errores**
- _Real:_ devuelve `false` si el email está vacío o la contraseña tiene menos de 8 caracteres.
  Cualquier excepción se captura y devuelve `false` (`debugPrint` del error).
- _Propuesto:_ `401 Unauthorized` (credenciales inválidas), `400 Bad Request` (formato).

> Apoyo: `getSavedCredentials() → Future<Map<String,String?>>` ([auth_provider.dart:18](../lib/providers/auth_provider.dart))
> devuelve `{email, password}` guardados si `rememberMe == 'true'`, para autorrellenar el formulario.
> `logout() → Future<void>` ([auth_provider.dart:72](../lib/providers/auth_provider.dart)) limpia el
> estado de sesión local (conserva credenciales si "Recuérdame" estaba activo).

### 4.1.2. Registro de usuario

- **Implementado:** `AuthProvider.createUser({required String email, required String password, required String confirmPassword}) → Future<Map<String,dynamic>>` ([auth_provider.dart:82](../lib/providers/auth_provider.dart))
- **Endpoint propuesto:** `POST /api/auth/register`

**Cuerpo**
```json
{ "email": "usuario@dominio.com", "password": "Secreta123", "confirmPassword": "Secreta123" }
```

**Respuesta (real)** — tras `Future.delayed(500ms)`:
```json
{ "success": true, "message": "Usuario creado exitosamente" }
```

**Respuesta propuesta** — `201 Created` con el usuario creado (y, opcionalmente, email de verificación).

**Errores** (mismo formato `{success:false, message}`; validados en orden):
| Condición | message |
| --- | --- |
| email vacío | `El email es requerido` |
| email con formato inválido | `Por favor ingresa un email válido` |
| password vacía | `La contraseña es requerida` |
| password < 8 caracteres | `La contraseña debe tener al menos 8 caracteres` |
| password ≠ confirmPassword | `Las contraseñas no coinciden` |
| password sin letra+número | `La contraseña debe contener al menos una letra y un número` |
| excepción interna | `Error interno del servidor` |

> _Propuesto además:_ `409 Conflict` si el email ya existe (hoy no se comprueba: siempre "exitoso").

### 4.1.3. Recuperación de contraseña

- **Implementado:** `AuthProvider.sendPasswordResetEmail(String email) → Future<Map<String,dynamic>>` ([auth_provider.dart:225](../lib/providers/auth_provider.dart))
- **Endpoint propuesto:** `POST /api/auth/password/reset`

**Cuerpo**
```json
{ "email": "usuario@dominio.com" }
```

**Respuesta (real)** — tras `Future.delayed(500ms)`:
```json
{ "success": true, "message": "Email de recuperación enviado exitosamente" }
```

**Respuesta propuesta** — `202 Accepted` (envío de email de recuperación).

**Errores**
| Condición | message |
| --- | --- |
| email vacío | `El email es requerido` |
| email con formato inválido | `Por favor ingresa un email válido` |
| excepción interna | `Error interno del servidor` |

### 4.1.4. Cambio de contraseña

- **Implementado:** `AuthProvider.changePassword({required String email, required String currentPassword, required String newPassword, required String confirmNewPassword}) → Future<Map<String,dynamic>>` ([auth_provider.dart:127](../lib/providers/auth_provider.dart))
- **Endpoint propuesto:** `PUT /api/auth/password` (autenticado)

**Cuerpo**
```json
{
  "email": "usuario@dominio.com",
  "currentPassword": "Secreta123",
  "newPassword": "Secreta456",
  "confirmNewPassword": "Secreta456"
}
```

**Respuesta (real)** — tras `Future.delayed(500ms)`:
```json
{ "success": true, "message": "Contraseña cambiada exitosamente" }
```

**Respuesta propuesta** — `200 OK`.

**Errores** (validados en orden):
| Condición | message |
| --- | --- |
| email vacío | `El email es requerido` |
| email con formato inválido | `Por favor ingresa un email válido` |
| currentPassword vacía | `La contraseña actual es requerida` |
| newPassword vacía | `La nueva contraseña es requerida` |
| newPassword < 8 caracteres | `La nueva contraseña debe tener al menos 8 caracteres` |
| newPassword ≠ confirmNewPassword | `Las contraseñas nuevas no coinciden` |
| newPassword == currentPassword | `La nueva contraseña debe ser diferente a la actual` |
| newPassword sin letra+número | `La nueva contraseña debe contener al menos una letra y un número` |
| excepción interna | `Error interno del servidor` |

> _Propuesto además:_ `401` si `currentPassword` no coincide (hoy no se verifica contra ningún dato).

### 4.1.5. Eliminación de cuenta

> No aparece numerado en la sección 4 del .docx, pero existe en el código y en la UI.

- **Implementado:** `AuthProvider.deleteUser({required String email, required String password, required String confirmPassword, required String confirmationText}) → Future<Map<String,dynamic>>` ([auth_provider.dart:178](../lib/providers/auth_provider.dart))
- **Endpoint propuesto:** `DELETE /api/auth/account` (autenticado)

**Cuerpo**
```json
{
  "email": "usuario@dominio.com",
  "password": "Secreta123",
  "confirmPassword": "Secreta123",
  "confirmationText": "ELIMINAR"
}
```

**Respuesta (real)** — tras `Future.delayed(500ms)`:
```json
{ "success": true, "message": "Cuenta eliminada exitosamente" }
```

**Respuesta propuesta** — `200 OK` o `204 No Content`.

**Errores** (validados en orden):
| Condición | message |
| --- | --- |
| email vacío | `El email es requerido` |
| email con formato inválido | `Por favor ingresa un email válido` |
| password vacía | `La contraseña es requerida` |
| confirmPassword vacía | `La confirmación de contraseña es requerida` |
| password ≠ confirmPassword | `Las contraseñas no coinciden` |
| confirmationText vacío | `Debes escribir ELIMINAR para confirmar` |
| confirmationText ≠ "eliminar" (case-insensitive) | `Debes escribir exactamente "ELIMINAR" para confirmar` |
| excepción interna | `Error interno del servidor` |

---

## 4.2. Aparcamientos / Estaciones

Implementado en [`lib/providers/stations_provider.dart`](../lib/providers/stations_provider.dart).
**No hay llamada de red:** las estaciones son **8 registros hardcodeados** en
`_loadMockStations()` ([stations_provider.dart:147](../lib/providers/stations_provider.dart)).
Los favoritos se persisten en `SharedPreferences` (clave `bikeParking_favorites`).

### 4.2.1. Listar estaciones

- **Implementado:** `StationsProvider.stations` (getter) y `getFilteredStations() → List<BikeStation>` ([stations_provider.dart:101](../lib/providers/stations_provider.dart))
- **Endpoint propuesto:** `GET /api/stations`

**Parámetros (filtros, hoy en memoria local; propuestos como query params):**
| Parámetro | Tipo | Efecto |
| --- | --- | --- |
| `search` (`searchQuery`) | String | filtra por `name` o `address` (contains, case-insensitive) |
| `showOnlyAvailable` | bool | solo estaciones con `availableSpots > 0` |
| `showOnlyFavorites` | bool | solo estaciones marcadas como favoritas |
| `sortBy` | String | `name` (alfabético) \| `availability` (desc) \| `none` |

**Respuesta (real)** — lista de `BikeStation`:
```json
[ { "id": "1", "name": "Plaza Mayor", "address": "Calle Mayor, 1", "availableSpots": 3, "totalSpots": 10, "lat": 40.4155, "lng": -3.7074 } ]
```
**Propuesto:** `200 OK` con el array anterior.

### 4.2.2. Obtener estación por id

- **Implementado:** `StationsProvider.getStationById(String id) → BikeStation?` ([stations_provider.dart:67](../lib/providers/stations_provider.dart))
- **Endpoint propuesto:** `GET /api/stations/{id}`

**Respuesta (real):** el `BikeStation` o `null` si no existe.
**Errores propuestos:** `404 Not Found` si el id no existe.

### 4.2.3. Marcar / desmarcar favorito

- **Implementado:** `StationsProvider.toggleFavorite(String stationId) → Future<void>` ([stations_provider.dart:31](../lib/providers/stations_provider.dart)); consulta con `isFavorite(id) → bool`.
- **Endpoint propuesto:** `POST /api/stations/{id}/favorite` y `DELETE /api/stations/{id}/favorite` (autenticado).

**Respuesta (real):** ninguna (actualiza la lista local y persiste en `SharedPreferences`).
**Propuesto:** `200 OK` / `204 No Content`.

### 4.2.4. Disponibilidad de plazas

- **Implementado:** `StationsProvider.updateStationAvailability(String stationId, int newAvailableSpots) → void` ([stations_provider.dart:52](../lib/providers/stations_provider.dart)). Es una **actualización local** del mock (se usa al reservar), no una consulta a servidor.
- **Propuesto:** la disponibilidad en tiempo real vendría incluida en `GET /api/stations` o por un canal push/websocket (la spec menciona "tiempo real"; hoy no existe).

---

## 4.3. Reservas (creación y cancelación)

Implementado en [`lib/providers/reservations_provider.dart`](../lib/providers/reservations_provider.dart).
Toda la lógica (temporizadores, estados) es **local**, con `Timer.periodic`. El historial se persiste
en `SharedPreferences` (clave `bikeParking_history`). Tiempos en `AppConstants`:
reserva **30 min** (1800 s), uso máximo **14 h** (50400 s), aviso a **5 min** (300 s).

Estados de la reserva activa (`ReservationState`): `reserved` → `inUse`.

### 4.3.1. Crear reserva

- **Implementado:** `ReservationsProvider.createReservation(BikeStation station) → Future<bool>` ([reservations_provider.dart:37](../lib/providers/reservations_provider.dart))
- **Endpoint propuesto:** `POST /api/reservations`

**Cuerpo propuesto**
```json
{ "stationId": "1" }
```

**Respuesta (real):** `true` si se crea; arranca el temporizador de 30 min, estado `reserved`.
**Propuesto:** `201 Created` con el detalle de la reserva activa.

**Errores (real):** devuelve `false` si `station.availableSpots <= 0` (sin plazas) o si ya existe
una reserva activa (`_activeReservation != null`). Excepción → `false`.
**Propuesto:** `409 Conflict` (sin plazas / ya tiene reserva activa).

### 4.3.2. Abrir puerta (iniciar uso)

- **Implementado:** `ReservationsProvider.openDoor() → void` ([reservations_provider.dart:96](../lib/providers/reservations_provider.dart))
- **Endpoint propuesto:** `POST /api/reservations/{id}/open-door`

**Comportamiento (real):** la primera vez transiciona de `reserved` a `inUse`, detiene el temporizador
de reserva y arranca el de uso (hasta 14 h). No interactúa con hardware real. Sin valor de retorno.
**Propuesto:** `200 OK`. Errores: `404`/`409` si no hay reserva activa.

### 4.3.3. Cancelar reserva / finalizar uso

- **Implementado:** `cancelReservation() → Future<void>` ([reservations_provider.dart:63](../lib/providers/reservations_provider.dart)) y `finishUsage() → Future<void>` (alias de `cancelReservation`, [reservations_provider.dart:114](../lib/providers/reservations_provider.dart)).
- **Endpoint propuesto:** `DELETE /api/reservations/{id}` (cancelar) / `POST /api/reservations/{id}/finish` (finalizar uso).

**Comportamiento (real):** crea un `ReservationRecord` y lo inserta al principio del historial; el
`status` es `completed` si `duration > 0`, o `cancelled` si `duration == 0`. Limpia la reserva activa.
Si la reserva de 30 min expira sin abrir puerta, el temporizador llama automáticamente a
`cancelReservation()` (quedaría como histórico). No se distingue `expired` explícitamente al expirar.
**Propuesto:** `200 OK` con el `ReservationRecord` resultante.

### 4.3.4. Historial y estadísticas

> Funcionalidad presente en el código (no detallada en la sección 4 del .docx).

- **Implementado:**
  - `reservationHistory` (getter) — lista de `ReservationRecord` cargada de `SharedPreferences`.
  - `getReservationStatistics()` → `{ total, completed, averageDuration }` ([reservations_provider.dart:119](../lib/providers/reservations_provider.dart)).
  - `getUserStatistics()` → `{ totalReservations, totalTimeMinutes, favoriteStation }` ([reservations_provider.dart:135](../lib/providers/reservations_provider.dart)).
  - `getStatistics()` → `{ totalReservations, completedReservations, cancelledReservations, expiredReservations, totalUsageTime, averageUsageTime, completionRate, cancellationRate, totalSavings, bestMonth }` ([reservations_provider.dart:256](../lib/providers/reservations_provider.dart)).
- **Endpoint propuesto:** `GET /api/reservations` (historial) y `GET /api/reservations/stats` (autenticado).

---

## Servicios externos reales (no son API propia)

- **Google Maps** (`google_maps_flutter`): render del mapa y marcadores en
  `bike_stations_map.dart` y `active_reservation_screen.dart`. Requiere API key
  (ver `README.md` → *Configurar Google Maps*).
- **Llamada de teléfono de soporte** (`url_launcher`): abre `tel:+34900000000`
  (`AppConstants.supportPhone`) desde Ajustes / helpers. No es un endpoint HTTP.

## Resumen de brechas frente al .docx (sección 4)

| Lo que pide el .docx | Estado en código |
| --- | --- |
| Endpoints REST de auth (4.1.1–4.1.4) | Simulados en `AuthProvider`, sin red ni servidor |
| Tokens JWT con expiración | No existen |
| Email de verificación / 2FA | No existe (registro siempre "exitoso") |
| Endpoints de aparcamientos (4.2) | Datos mock hardcodeados, sin red |
| Disponibilidad en tiempo real | Solo actualización local del mock |
| Endpoints de reservas (4.3) | Lógica local con temporizadores, sin red |
| HTTPS / sanitización / bcrypt | No aplicable hoy (sin backend) |
