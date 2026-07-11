# Contrato de API REST — Backend AparcaBicis (Fase 2)

> ✅ **CONTRATO CERRADO.** Todas las decisiones de contrato están resueltas (P1, P3, P4, P5 y la regla
> de reserva única). Quedan **dos pendientes abiertos que no bloquean el contrato** y se cierran en
> implementación: **P2** (subida del PDF de menores) y **P6** (validación formal RGPD del borrado). Ver §7.

- **Fecha:** 2026-06-02
- **Fase:** 2 de 2 — **contrato de API**. Se diseña **sobre el modelo de datos cerrado**
  ([modelo-datos.md](modelo-datos.md)). **No se implementa código**, solo el contrato.
- **Fuentes:** [modelo-datos.md](modelo-datos.md), [ADR 0001](adr/0001-backend.md),
  [ADR 0002](adr/0002-multi-ciudad.md), [diagnóstico](diagnostico-api-vs-app.md) y los **endpoints
  reales** en `repos/api` (`reserva`, `apertura`, `end_sesion`, `info_plazas`, `info_usr`, `token`,
  `check_inact_user`). Para los endpoints reutilizados, se parte de su **contrato real**, no de uno ideal.
- **Decisiones respetadas:** multi-ciudad por despliegue (**sin parámetro de ciudad** en ninguna ruta),
  **sin tarifas** en v1, **push diferido** (no se diseñan endpoints de push), **2FA diferido** (login
  preparado para el paso TOTP, sin implementarlo), **disponibilidad derivada** (no ocupación física).
  Patrón propio de AparcaBicis (no SAE / no `rutas_servicio`).

---

## 0. Resumen: qué es NUEVO y qué REUTILIZA lo existente

| # | Endpoint app-facing | Estado | Reusa / Origen |
|---|---|---|---|
| **Auth de usuario (nuevo subsistema sobre `TITULARES`)** | | | |
| 1 | `POST /api/auth/register` | 🆕 NUEVO | — |
| 2 | `POST /api/auth/email/verify` | 🆕 NUEVO | — |
| 3 | `POST /api/auth/email/resend` | 🆕 NUEVO | — |
| 4 | `POST /api/auth/login` | 🆕 NUEVO | (preparado para 2FA) |
| 5 | `POST /api/auth/refresh` | 🆕 NUEVO | — |
| 6 | `POST /api/auth/logout` | 🆕 NUEVO | — |
| 7 | `PUT /api/auth/password` | 🆕 NUEVO | — |
| 8 | `POST /api/auth/password/forgot` | 🆕 NUEVO | infra email de `check_inact_user` (PHPMailer) |
| 9 | `POST /api/auth/password/reset` | 🆕 NUEVO | — |
| 10 | `DELETE /api/auth/account` | 🆕 NUEVO | transacción de borrado §4.5 de modelo-datos |
| **Estaciones** | | | |
| 11 | `GET /api/stations` | 🆕 NUEVO | generaliza `info_plazas` + `APARCABICIS` |
| 12 | `GET /api/stations/{id}` | 🆕 NUEVO | `info_plazas` + `APARCABICIS` |
| **Reservas** | | | |
| 13 | `POST /api/reservations` | ♻️ REUTILIZA (adaptado) | `reserva/reserva.php` |
| 14 | `GET /api/reservations/active` | ♻️ REUTILIZA (adaptado) | `info_usr/info_usr.php` |
| 15 | `POST /api/reservations/active/open-door` | ♻️ REUTILIZA (adaptado) | `apertura/open_locker.php` |
| 16 | `POST /api/reservations/active/finish` | ♻️ REUTILIZA (adaptado) | `end_sesion/end_sesion.php` |
| 17 | `DELETE /api/reservations/active` (cancelar) | ♻️ REUTILIZA (adaptado) | `end_sesion/end_sesion.php` |
| 18 | `GET /api/reservations/history` | 🆕 NUEVO | lee `LOG_SESIONES` (§4.4 modelo-datos) |
| 19 | `GET /api/reservations/stats` | 🆕 NUEVO | métricas derivadas de `LOG_SESIONES` (PHP) |
| **Fuera del contrato app** (internos, no se tocan) | | | |
| — | `token` (regenera APIkey de cliente), `check_inact_user` (cron de sanción) | 🔒 INTERNO | auth de cliente `API_usr` / job |

---

## 1. Convenciones generales

### 1.1. Cambio de modelo de autenticación (clave)

El backend actual autentica al **cliente** (`UsrAPI` + `APIkey` de `API_usr`) y **confía** en un
`IDusrAPP` que el cliente envía sin verificar (agujero señalado en el diagnóstico). El nuevo contrato
**app-facing** cambia esto:

- La app se autentica como **usuario** con **JWT** (sujeto = titular de `TITULARES`). **La app ya no
  envía `UsrAPI`/`APIkey`/`IDusrAPP`.**
- El backend deriva el `IDusrAPP` (= email del usuario, `ti_email`) **del JWT**, no del cuerpo.
- La auth de **cliente** (`API_usr`, endpoint `token`) **no se elimina ni se toca**: pasa a ser un
  detalle **interno servidor↔hardware/legacy**, nunca expuesto a la app.

### 1.2. URL base

`https://{host-de-la-ciudad}/api` — el host lo fija el **despliegue** de cada ciudad (ADR 0002). **No
hay parámetro de ciudad** en ninguna ruta ni cuerpo.

### 1.3. Envoltorio de respuesta (patrón AparcaBicis, se conserva)

Todas las respuestas usan el envoltorio real ya existente:

```json
{ "status": "ok", "result": { } }
```

- **Éxito:** `status: "ok"`, `result` con los datos.
- **Error:** `result` contiene `error_id` (string, = código HTTP) y `error_msg`. Los endpoints **nuevos**
  añaden además `error_code` (string estable, legible por máquina; p. ej. `EMAIL_NOT_VERIFIED`) para que
  la app no dependa del texto.

```json
{ "status": "error", "result": { "error_id": "401", "error_code": "INVALID_CREDENTIALS", "error_msg": "Email o contraseña incorrectos" } }
```

> Cuirks heredados que se mantienen por compatibilidad en los endpoints reutilizados: `error_404` emite
> `status: "No encontrado"` y `error_402` emite `status: "completed"`. Los endpoints **nuevos**
> normalizan siempre a `status: "error"`.

### 1.4. Autenticación JWT

- **Access token:** `Authorization: Bearer <jwt>`. Vida **15 min** (P5, confirmado). Claims:
  `sub` (= `ti_id`), `email`, `email_verified` (bool), `iat`, `exp`. Firmado HS256/RS256 (clave en
  config del despliegue).
- **Refresh token:** opaco, vida **30 días** (P5, confirmado), almacenado **hasheado** en
  `titulares_refresh_tokens` (rotación + revocación). Se entrega en login/refresh.
- Endpoints **protegidos** (estaciones y reservas) exigen `Authorization: Bearer`. Sin token válido →
  `401 TOKEN_INVALID`; token caducado → `401 TOKEN_EXPIRED` (la app llama a `refresh`).

### 1.5. Verificación de email OBLIGATORIA (D5)

La verificación es **completamente obligatoria**: un usuario **no verificado no puede operar**.

- Tras `register`, la cuenta existe con `ti_email_verificado = 0` y `ti_password = '0'` (recién creada).
- **`login` de un usuario no verificado responde `403 EMAIL_NOT_VERIFIED`** (con opción de reenvío). No
  se emiten tokens hasta verificar.
- Al verificar: `ti_email_verificado = 1` y `ti_password = '1'` (cuenta activa).

### 1.6. Login preparado para 2FA (diferido, NO implementado en v1)

El esquema de respuesta de `login` **reserva** la forma para el futuro paso TOTP, pero en v1 **nunca**
se activa (`ti_2fa_habilitado` siempre 0): si algún día se habilita, `login` podrá responder
`200` con `{ "mfa_required": true, "mfa_token": "<temporal>" }` en lugar de los tokens, y se añadiría
`POST /api/auth/login/totp`. **En v1 no existe ese endpoint ni esa rama.**

### 1.7. Estado del usuario para poder operar

Una acción de reserva exige, en este orden (lógica de servidor, modelo §2.1):

1. JWT válido (usuario autenticado).
2. `ti_email_verificado = 1` (si no → `403 EMAIL_NOT_VERIFIED`).
3. Sin sanción vigente en `usuarios_bici` (`activo = 1` y `inactivohasta` pasado); si sancionado →
   `403 USER_SUSPENDED` con `inactivo_hasta`.

### 1.7.bis. REGLA FIRME: una reserva activa por usuario

**Un usuario tiene como máximo UNA reserva/uso activo a la vez. Es una regla firme e inalterable del
sistema, no un supuesto.** Mientras exista una reserva (`reserved`) o un uso (`inUse`) en curso, no se
puede crear otra: `POST /api/reservations` responde **`409 ALREADY_HAS_RESERVATION`** (código
definitivo). El usuario debe finalizar/cancelar la activa antes de reservar de nuevo. Esta regla
también condiciona el borrado de cuenta (§2.10, P3).

### 1.8. Códigos de estado HTTP usados

`200` OK · `201` Created · `202` Accepted · `204` No Content · `400` Bad Request · `401` Unauthorized
· `403` Forbidden · `404` Not Found · `409` Conflict · `422` Validación · `429` Rate limit · `500` Error.

---

## 2. AUTH DE USUARIO (nuevo, sobre `TITULARES`)

> Distinto de la auth de cliente (`API_usr`), que no se toca. Todos estos endpoints operan sobre
> `TITULARES` y sus tablas satélite (`titulares_email_tokens`, `titulares_password_resets`,
> `titulares_refresh_tokens`).

### 2.1. `POST /api/auth/register` — Registro 🆕

- **Auth:** ninguna.
- **Cuerpo:**
```json
{ "email": "usuario@dominio.com", "password": "Secreta123", "confirmPassword": "Secreta123",
  "nombre": "Nombre Apellido", "dni": "12345678A", "telefono": "600000000",
  "fechaNacimiento": "2001-05-20", "direccion": "Calle Mayor 1", "poblacion": "Palma" }
```
- **Reglas:** email único (`ti_email`), contraseña ≥8 con letra+número (regla actual de la app), DNI/NIE.
  Si `fechaNacimiento` indica **menor de edad**, se exige el flujo de tutor (ver nota menores).
- **Respuesta `201`:**
```json
{ "status": "ok", "result": { "email": "usuario@dominio.com", "email_verified": false,
  "message": "Cuenta creada. Revisa tu correo para verificar la cuenta." } }
```
- **Efecto:** crea fila en `TITULARES` (`ti_password='0'`, `ti_email_verificado=0`, `ti_pass_hash =
  bcrypt(password)`), genera token en `titulares_email_tokens` y envía email de verificación.
- **Errores:**

| HTTP | error_code | Cuándo |
|---|---|---|
| 422 | `EMAIL_REQUIRED` / `EMAIL_INVALID` | email vacío o formato inválido |
| 422 | `PASSWORD_WEAK` | <8 car. o sin letra+número |
| 422 | `PASSWORD_MISMATCH` | password ≠ confirmPassword |
| 422 | `MINOR_GUARDIAN_REQUIRED` | menor sin datos/autorización de tutor |
| 409 | `EMAIL_TAKEN` | el email ya existe en `TITULARES` |
| 500 | `INTERNAL` | error interno |

> **Menores (D10):** si la fecha de nacimiento es de un menor, el registro exige `tutorNombre` y la
> **subida del PDF de autorización** (`ti_authorization_pdf`). El mecanismo de subida del PDF
> (multipart vs. endpoint aparte) se concreta en implementación; el contrato solo fija que es requisito
> de alta. Base legal y validación fina = pendiente RGPD (ver modelo-datos §1.1/§4.5).

### 2.2. `POST /api/auth/email/verify` — Verificar email 🆕

- **Auth:** ninguna (el token del email es la credencial).
- **Cuerpo:** `{ "token": "<token-del-email>" }`
- **Respuesta `200`:** `{ "status": "ok", "result": { "email_verified": true } }`
- **Efecto:** marca `ti_email_verificado=1`, `ti_password='1'`, consume el token.
- **Errores:** `400 TOKEN_INVALID` (no existe), `410 TOKEN_EXPIRED` (caducado/usado).

### 2.3. `POST /api/auth/email/resend` — Reenviar verificación 🆕

- **Auth:** ninguna. **Cuerpo:** `{ "email": "usuario@dominio.com" }`
- **Respuesta `202`** (siempre, no revela si el email existe):
  `{ "status": "ok", "result": { "message": "Si la cuenta existe y no está verificada, se ha reenviado el correo." } }`
- **Errores:** `429 RATE_LIMITED` (límite de reenvíos).

### 2.4. `POST /api/auth/login` — Login (JWT + refresh) 🆕

- **Auth:** ninguna. **Cuerpo:** `{ "email": "...", "password": "...", "rememberMe": true }`
- **Respuesta `200`:**
```json
{ "status": "ok", "result": {
  "access_token": "<jwt>", "token_type": "Bearer", "expires_in": 900,
  "refresh_token": "<opaco>", "refresh_expires_in": 2592000,
  "user": { "email": "usuario@dominio.com", "nombre": "Nombre Apellido", "email_verified": true } } }
```
- **Efecto:** verifica `bcrypt`; crea refresh token (hash en `titulares_refresh_tokens`); actualiza
  `ti_ultimo_login_at`; resetea `ti_intentos_fallidos`.
- **Errores:**

| HTTP | error_code | Cuándo |
|---|---|---|
| 401 | `INVALID_CREDENTIALS` | email/contraseña incorrectos (mensaje genérico, no revela cuál) |
| 403 | `EMAIL_NOT_VERIFIED` | cuenta sin verificar (D5); incluye `can_resend: true` |
| 403 | `USER_SUSPENDED` | sanción vigente; incluye `inactivo_hasta` |
| 429 | `RATE_LIMITED` | demasiados intentos (`ti_bloqueado_hasta`) |

> **2FA (diferido):** en v1 nunca devuelve `mfa_required`. Forma reservada en §1.6.

### 2.5. `POST /api/auth/refresh` — Renovar access token 🆕

- **Auth:** refresh token. **Cuerpo:** `{ "refresh_token": "<opaco>" }`
- **Respuesta `200`:** nuevos `access_token` (+ `expires_in`) y `refresh_token` rotado.
- **Efecto:** valida hash en `titulares_refresh_tokens` (no caducado/revocado), **rota** (revoca el
  anterior, emite uno nuevo).
- **Errores:** `401 REFRESH_INVALID`, `401 REFRESH_EXPIRED`, `401 REFRESH_REVOKED`.

### 2.6. `POST /api/auth/logout` — Cerrar sesión 🆕

- **Auth:** `Bearer`. **Cuerpo:** `{ "refresh_token": "<opaco>" }` (opcional; si falta, revoca el del dispositivo actual).
- **Respuesta `204`** (sin cuerpo). **Efecto:** marca `trt_revocado_at` del refresh token.
- **Errores:** `401 TOKEN_INVALID`.

### 2.7. `PUT /api/auth/password` — Cambiar contraseña 🆕

- **Auth:** `Bearer`.
- **Cuerpo:** `{ "currentPassword": "...", "newPassword": "...", "confirmNewPassword": "..." }`
- **Respuesta `200`:** `{ "status": "ok", "result": { "message": "Contraseña actualizada" } }`
- **Efecto:** valida `currentPassword`; guarda `ti_pass_hash` nuevo; **revoca todos los refresh tokens**
  del usuario (fuerza re-login en otros dispositivos).
- **Errores:** `401 INVALID_CURRENT_PASSWORD`, `422 PASSWORD_WEAK`, `422 PASSWORD_MISMATCH`,
  `422 PASSWORD_SAME` (nueva = actual).

### 2.8. `POST /api/auth/password/forgot` — Solicitar reset 🆕

- **Auth:** ninguna. **Cuerpo:** `{ "email": "usuario@dominio.com" }`
- **Respuesta `202`** (siempre, no revela existencia):
  `{ "status": "ok", "result": { "message": "Si la cuenta existe, se ha enviado un correo de recuperación." } }`
- **Efecto:** genera token en `titulares_password_resets` y envía email (reusa la **infraestructura
  PHPMailer** ya presente en `check_inact_user`).
- **Errores:** `429 RATE_LIMITED`.

### 2.9. `POST /api/auth/password/reset` — Confirmar reset 🆕

- **Auth:** token del email. **Cuerpo:** `{ "token": "<token>", "newPassword": "...", "confirmNewPassword": "..." }`
- **Respuesta `200`:** `{ "status": "ok", "result": { "message": "Contraseña restablecida" } }`
- **Efecto:** valida token; fija `ti_pass_hash`; consume token; revoca refresh tokens existentes.
- **Errores:** `400 TOKEN_INVALID`, `410 TOKEN_EXPIRED`, `422 PASSWORD_WEAK`, `422 PASSWORD_MISMATCH`.

### 2.10. `DELETE /api/auth/account` — Borrado de cuenta (supresión completa) 🆕

- **Auth:** `Bearer` + reconfirmación.
- **Cuerpo:** `{ "password": "...", "confirmationText": "ELIMINAR" }`
- **Respuesta `200`:** `{ "status": "ok", "result": { "message": "Cuenta eliminada" } }` (o `204`).
- **Efecto:** ejecuta la **transacción de borrado físico completo de §4.5 del modelo**: borra
  `TITULARES` + satélites (cascada), borra filas operativas de `usuarios_bici`, y **borra por email**
  las filas del usuario en `LOG_SESIONES`, `DATALOG`, `log_estado_usuarios`; libera plaza si hubiera
  sesión activa; revoca todos los tokens. **No queda PII.**
- **Regla firme (P3):** **no se permite borrar la cuenta con una reserva/uso activo.** Si el usuario
  tiene una reserva (`reserved`) o un uso (`inUse`) en curso, `DELETE /api/auth/account` responde
  **`409 ACTIVE_SESSION`** y debe finalizar/cancelar antes de poder borrarse. El backend comprueba el
  estado activo (vía `info_usr`) antes de iniciar la transacción de borrado.
- **Errores:** `401 INVALID_PASSWORD`, `422 CONFIRMATION_REQUIRED` (texto ≠ "ELIMINAR"),
  `409 ACTIVE_SESSION` (hay reserva/uso activo — debe finalizarse primero).

---

## 3. ESTACIONES

> Protegidos con `Bearer`. La **disponibilidad es derivada** de `PLAZAS.pla_status` (no ocupación
> física). Coordenadas y datos de catálogo salen de `APARCABICIS`.

### 3.1. `GET /api/stations` — Lista de estaciones 🆕 (generaliza `info_plazas`)

- **Auth:** `Bearer`.
- **Query (opcionales):** `search` (nombre/dirección), `onlyAvailable` (bool), `electric` (bool, plazas
  con cargador), `sort` (`name`|`availability`). *(Favoritos NO: son locales en el dispositivo, A1.)*
- **Respuesta `200`:**
```json
{ "status": "ok", "result": { "stations": [
  { "id": 5245, "name": "Aparcabicis Plaça Major", "address": "Plaça Major, 1", "city": "Palma",
    "lat": 39.5696, "lng": 2.6502, "capacity": 10,
    "available": 3, "reserved": 2, "occupied": 5,
    "availableElectric": 1, "availableNonElectric": 2,
    "status_color": "green" } ] } }
```
- **Origen de cada campo:** `id/name/address/city/lat/lng/capacity` ← `APARCABICIS`
  (`apbi_id`/`apbi_description`/`apbi_address`/`apbi_city`/`apbi_latitud`/`apbi_longitud`/`apbi_capacity`).
  `available/reserved/occupied` ← `COUNT` sobre `PLAZAS` por `pla_status` (como `info_plazas`, pero para
  todas las estaciones). `availableElectric/NonElectric` ← `COUNT` con `pla_elect`.
- **`status_color`** (marcadores del mapa): derivado en servidor por **porcentaje de plazas disponibles
  sobre la capacidad** de la estación (`pct = available / capacity * 100`) — **P1 cerrado:**
    - `green`  → `pct > 75`
    - `amber`  → `40 ≤ pct ≤ 75`  (los límites 75 y 40 caen en ámbar)
    - `red`    → `pct < 40`

  Es decir: `> 75%` verde; `[40%, 75%]` ámbar; `< 40%` rojo.
- **Errores:** `401 TOKEN_INVALID/EXPIRED`.

### 3.2. `GET /api/stations/{id}` — Detalle de estación 🆕

- **Auth:** `Bearer`. **Path:** `id` = `apbi_id`.
- **Respuesta `200`:** un objeto estación con la misma forma que arriba (opcional: desglose de plazas).
- **Errores:** `404 STATION_NOT_FOUND`, `401 ...`.

---

## 4. RESERVAS

> Estos endpoints **reutilizan** los manejadores reales. Por cada uno se muestra primero su **contrato
> real existente** (cliente + IDusrAPP) y luego la **adaptación app-facing** (JWT, RESTful). La
> adaptación: (a) auth pasa de `UsrAPI/APIkey` + `IDusrAPP` del cuerpo → **JWT** (email = sujeto);
> (b) el backend aporta internamente las credenciales de cliente y el `IDusrAPP`; (c) se conserva el
> envoltorio `{status,result}`.

### 4.1. `POST /api/reservations` — Crear reserva ♻️ (reusa `reserva/reserva.php`)

**Contrato real existente** — `POST` a `reserva`:
- Cuerpo real: `{ "UsrAPI", "APIkey", "IDlocker", "IDusrAPP", "Tipo_lock" }` (`Tipo_lock`: 0 sin
  enchufe, 1 con enchufe, 2 indistinto).
- Respuesta real `result`: `{ "IDlocker", "Tipo_lock", "IDusrAPP", "IDspace", "Time", "EndTime", "action" }`.
- Errores reales: `400` (faltan params), `404` ("Usuario inexistente"/"Pasword no valida"/"No existe
  ninguna plaza disponible" si `Tipo_lock!=2`), `403` ("Usuario dado de baja"), `402` (sin plaza tras
  agotar reintentos). Reserva caduca a **+30 min** (`pla_vctoreserv`); `session_id` **no** se devuelve.

**Adaptación app-facing:**
- **Auth:** `Bearer`. **Cuerpo:** `{ "stationId": 5245, "electric": false }`
  (`stationId` → `IDlocker`; `electric` → `Tipo_lock`: `false`→2 indistinto / `true`→1 con cargador;
  o se omite para indistinto).
- **Respuesta `201`:**
```json
{ "status": "ok", "result": {
  "stationId": 5245, "spaceId": 2, "electric": false,
  "state": "reserved", "startTime": "2026-06-02T18:00:00", "expiresAt": "2026-06-02T18:30:00" } }
```
- **Mapeo:** `IDusrAPP` ← email del JWT; `UsrAPI/APIkey` ← credenciales internas del backend. `spaceId`
  = `IDspace`; `expiresAt` = `EndTime`.
- **Errores (adaptación, normalizados):**

| HTTP | error_code | Origen real |
|---|---|---|
| 409 | `NO_SPOTS_AVAILABLE` | `404`/`402` "No existe ninguna plaza disponible" |
| 409 | `ALREADY_HAS_RESERVATION` | el usuario ya tiene reserva/uso activo (**regla firme §1.7.bis**) |
| 403 | `USER_SUSPENDED` | sanción vigente (`usuarios_bici`) |
| 403 | `EMAIL_NOT_VERIFIED` | D5 |
| 404 | `STATION_NOT_FOUND` | locker inexistente |
| 401 | `TOKEN_*` | sin JWT válido |

### 4.2. `GET /api/reservations/active` — Estado de la reserva activa ♻️ (reusa `info_usr/info_usr.php`)

**Contrato real existente** — `POST` a `info_usr`:
- Cuerpo real: `{ "UsrAPI", "APIkey", "IDusrAPP" }`.
- Respuesta real `result`: `{ "IDestado", "IDlocker", "IDspace", "Time", "Time_end_reserva" (si reservada)
  | "Time_last_update" (si en uso), "note" }`. `IDestado`: 0 sin registro, 1 reservada, 2 en uso.

**Adaptación app-facing:**
- **Auth:** `Bearer`. **Sin cuerpo** (el usuario sale del JWT).
- **Respuesta `200`** (sin reserva):
```json
{ "status": "ok", "result": { "state": "none" } }
```
- **Respuesta `200`** (reservada / en uso):
```json
{ "status": "ok", "result": {
  "state": "reserved", "stationId": 5245, "spaceId": 2,
  "expiresAt": "2026-06-02T18:30:00", "openedAt": null } }
```
  (`state`: `none`|`reserved`|`inUse`; en `inUse` se incluye `openedAt`/`Time_last_update` y no `expiresAt`.)
- **Mapeo:** `IDestado` 0/1/2 → `state` none/reserved/inUse.
- **Errores:** `401 TOKEN_*`.

### 4.3. `POST /api/reservations/active/open-door` — Abrir puerta ♻️ (reusa `apertura/open_locker.php`)

**Contrato real existente** — `POST` a `apertura`:
- Cuerpo real: `{ "UsrAPI", "APIkey", "IDlocker", "IDspace", "IDusrAPP", "trigger" }` (`trigger=0`
  primera apertura: valida propiedad, llama al hardware por cURL a `pla_url`, confirma con HTTP 200 y
  pasa `pla_status` a 2; `trigger=1` aperturas sucesivas). Respuesta real `result`:
  `{ "IDlocker", "IDspace", "IDusrAPP", "Time", "action" }`. Errores: `400`, `403`, `404`, `500`
  ("Error en la apertura" si el hardware no responde 200).

**Adaptación app-facing:**
- **Auth:** `Bearer`. **Sin cuerpo** (plaza activa y usuario salen del estado + JWT).
- **El backend decide `trigger`** según `PLAZAS.pla_status` (reservada=2→`trigger 0`; en uso→`trigger 1`),
  la app **no** lo envía.
- **Respuesta `200`:**
```json
{ "status": "ok", "result": { "state": "inUse", "openedAt": "2026-06-02T18:10:00",
  "maxUsageEndsAt": "2026-06-03T08:10:00" } }
```
  (primera apertura transiciona `reserved → inUse`; `maxUsageEndsAt` = +14 h.)
- **Errores (adaptación):**

| HTTP | error_code | Origen real |
|---|---|---|
| 502 | `HARDWARE_OPEN_FAILED` | `500` "Error en la apertura" (hardware ≠ HTTP 200) |
| 409 | `NO_ACTIVE_RESERVATION` | no hay reserva/uso del usuario |
| 403 | `NOT_RESERVATION_OWNER` | `403` la plaza es de otro usuario |
| 404 | `STATION_OR_SPACE_NOT_FOUND` | `404` locker/plaza inexistente |
| 401 | `TOKEN_*` | sin JWT |

> **Confirmación de apertura (no ocupación física):** el éxito es el **HTTP 200 del comando** al
> hardware (`session.opened` en `LOG_SESIONES`), conforme al ADR. No hay evento físico de puerta para
> la app; `pla_puerta_st` es estado lógico interno.

### 4.4. `POST /api/reservations/active/finish` — Finalizar uso ♻️ y `DELETE /api/reservations/active` — Cancelar ♻️ (reusan `end_sesion/end_sesion.php`)

**Contrato real existente** — `POST` a `end_sesion`:
- Cuerpo real: `{ "UsrAPI", "APIkey", "IDlocker", "IDspace", "IDusrAPP", "Locksensor" }`. Según
  `pla_status`: `1`→`session.reserve_cancelled` (cancelación de reserva nunca abierta), `2`→
  `session.closed` (cierre de uso con duración/aperturas). Libera la plaza (`pla_status=0`). Respuesta
  real `result`: `{ "IDlocker", "IDspace", "IDusrAPP", "Time", "action" }`. Errores `400`, `403`
  ("Puerta abierta" si `Locksensor=1` y `pla_puerta_st≠0`), `500`.

**Adaptación app-facing** (dos rutas sobre el mismo manejador):
- **`POST /api/reservations/active/finish`** — finalizar un uso en curso (`inUse`).
- **`DELETE /api/reservations/active`** — cancelar una reserva aún no abierta (`reserved`).
- **Auth:** `Bearer`. **Sin cuerpo.** El backend resuelve `IDlocker/IDspace` desde la reserva activa del
  usuario y **decide `Locksensor`** internamente (la app no lo envía).
- **Respuesta `200`:**
```json
{ "status": "ok", "result": {
  "state": "completed", "endedAt": "2026-06-02T19:00:00", "durationMinutes": 50,
  "outcome": "completed" } }
```
  (`outcome`: `completed` si hubo uso / `cancelled` si era una reserva no abierta. Alimenta el historial.)
- **Errores (adaptación):**

| HTTP | error_code | Origen real |
|---|---|---|
| 409 | `DOOR_OPEN` | `403` "Puerta abierta" (`pla_puerta_st≠0`) |
| 409 | `NO_ACTIVE_RESERVATION` | `400` "plaza ya vacía"/no es del usuario |
| 403 | `NOT_RESERVATION_OWNER` | `400` intento sobre plaza de otro |
| 500 | `INTERNAL` | `500` error de actualización |
| 401 | `TOKEN_*` | sin JWT |

> Nota: si la reserva de 30 min caduca sin abrir, la **expiración la posee el servidor** (Redis/cron,
> modelo §… ADR 0001); no es una acción de la app. El resultado aparece en el historial como expirada.

### 4.5. `GET /api/reservations/history` — Historial 🆕 (lee `LOG_SESIONES`)

- **Auth:** `Bearer`. **Query:** `page`, `pageSize` (paginación); `from`, `to` (opcional).
- **Origen:** reconstruido desde `LOG_SESIONES` filtrando `ls_usuario_email = email del JWT` (columna
  generada del modelo §4.4), agrupando por `session_id`
  (`session.reserved → session.opened* → session.closed | session.reserve_cancelled`).
- **Respuesta `200`:**
```json
{ "status": "ok", "result": { "page": 1, "pageSize": 20, "total": 37, "items": [
  { "sessionId": "260602-45-02-64800", "stationId": 5245, "stationName": "Aparcabicis Plaça Major",
    "startTime": "2026-06-02T18:00:00", "endTime": "2026-06-02T19:00:00",
    "durationMinutes": 50, "openCount": 2, "outcome": "completed" } ] } }
```
  (`outcome`: `completed` | `cancelled` | `expired`, derivado del evento de cierre.)
- **Errores:** `401 TOKEN_*`.

### 4.6. `GET /api/reservations/stats` — Estadísticas del usuario 🆕 (P4 cerrado)

- **Estado:** confirmado. **Implementación en PHP** (mismo stack de la API, sin segunda tecnología).
- **Auth:** `Bearer`. **Query (opcional):** `from`, `to` (acota el periodo; por defecto, todo el histórico).
- **Origen:** métricas **derivadas de `LOG_SESIONES`** para `ls_usuario_email = email del JWT`,
  agregando por `session_id` (mismos eventos que el historial §4.5). **Sin tarifas ni "ahorro"** (A2).
- **Respuesta `200`:**
```json
{ "status": "ok", "result": {
  "totalUsos": 37,
  "totalReservas": 42,
  "cancelaciones": 3,
  "expiraciones": 2,
  "duracionMediaMinutos": 48,
  "duracionTotalMinutos": 1776,
  "estacionMasUsada": { "stationId": 5245, "stationName": "Aparcabicis Plaça Major", "usos": 12 },
  "periodo": { "from": null, "to": null } } }
```
- **Definición de cada métrica (derivadas de los eventos de cierre por sesión):**

| Campo | Cómo se deriva |
|---|---|
| `totalUsos` | nº de sesiones con `session.closed` (hubo apertura) |
| `totalReservas` | nº total de sesiones (`session.reserved`) |
| `cancelaciones` | nº de `session.reserve_cancelled` (reserva nunca abierta) |
| `expiraciones` | nº de sesiones caducadas a los 30 min sin abrir (evento de expiración) |
| `duracionMediaMinutos` | media de `duration_seconds` de los `session.closed` |
| `duracionTotalMinutos` | suma de `duration_seconds` de los `session.closed` |
| `estacionMasUsada` | `dock_id`/estación con más `session.closed`; se resuelve el nombre vía `APARCABICIS` |

- **Errores:** `401 TOKEN_*`.

> Estas métricas sustituyen el cálculo local que hoy hace la app (`getStatistics`/`getUserStatistics`),
> ahora con el historial **autoritativo del servidor** (A4). No se incluye "ahorro"/coste (A2, gratis).

---

## 5. Internos / fuera del contrato app (no se tocan)

- **`token`** (regenera `API_KEY` de cliente en `API_usr`): pertenece a la **auth de cliente**; el
  backend lo usa internamente para hablar con capas legacy/hardware. **No expuesto a la app.**
- **`check_inact_user`** (cron de sanción de 14 h): job operativo que escribe `usuarios_bici`/
  `log_estado_usuarios`. **No es endpoint de la app**; su efecto se refleja como `403 USER_SUSPENDED`.
- **`apertura_admin`, `end_sesion_admin`, `end_sesion_vR`, `block_admin`, `sensado_puertas`,
  `info_token`, `users/deactivate`:** administrativos / de control / sensado. Fuera del contrato app.
- **Push / FCM:** **diferido** (ADR 0001). No se diseñan endpoints en v1.
- **2FA / TOTP:** **diferido**. `login` reservado para el paso futuro (§1.6); no hay endpoint v1.

---

## 6. Mapa app ↔ manejador existente

| App-facing | Reusa | Adaptación principal |
|---|---|---|
| `POST /api/reservations` | `reserva` | JWT→IDusrAPP; `stationId/electric` → `IDlocker/Tipo_lock`; errores normalizados |
| `GET /api/reservations/active` | `info_usr` | JWT→IDusrAPP; `IDestado 0/1/2` → `state none/reserved/inUse` |
| `POST /api/reservations/active/open-door` | `apertura` | JWT; `trigger` lo decide el backend por `pla_status` |
| `POST /api/reservations/active/finish` | `end_sesion` | JWT; `Locksensor` interno; `outcome=completed` |
| `DELETE /api/reservations/active` | `end_sesion` | JWT; cancela reserva no abierta; `outcome=cancelled` |
| `GET /api/reservations/history` | (nuevo) lee `LOG_SESIONES` | columna `ls_usuario_email` (§4.4 modelo) |
| `GET /api/reservations/stats` | (nuevo) agrega `LOG_SESIONES` | métricas por sesión, en PHP; sin tarifas (A2) |
| `GET /api/stations[/{id}]` | (nuevo) `APARCABICIS`+`info_plazas` | agrega catálogo + disponibilidad derivada + coords |
| `POST/PUT/DELETE /api/auth/*` | (nuevo) `TITULARES`+satélites | subsistema de identidad de usuario |

---

## 7. Estado de pendientes

### 7.1. Cerrados (aplicados en este documento)

- **P1 — `status_color` por PORCENTAJE** (§3.1): verde `>75%`, ámbar `40–75%` (límites incluidos), rojo
  `<40%`, sobre `available/capacity`. ✅
- **P3 — Borrado con sesión activa: NO se permite** (§2.10). Con reserva/uso activo →
  `409 ACTIVE_SESSION`; debe finalizar/cancelar antes. Regla firme. ✅
- **P4 — `GET /api/reservations/stats`** (§4.6): endpoint dedicado, **en PHP**, métricas derivadas de
  `LOG_SESIONES`, sin tarifas/ahorro (A2). ✅
- **P5 — Vidas de token** (§1.4): access **15 min**, refresh **30 días**. ✅
- **Regla firme — una reserva activa por usuario** (§1.7.bis): `409 ALREADY_HAS_RESERVATION` definitivo.
  Regla inalterable del sistema. ✅

### 7.2. Abiertos (no bloquean el contrato; se cierran en implementación)

- **P2 — Subida del PDF de autorización de menores** (§2.1): mecanismo (multipart en `register` vs.
  endpoint dedicado) y validación de edad. Ligado a la base legal RGPD.
- **P6 — Validación formal RGPD** de la política de borrado (heredada de modelo-datos §4.5).

---

*Fase 2 = contrato. No se ha escrito código ni se ha modificado ningún endpoint existente. Los
endpoints reutilizados se describen partiendo de su contrato REAL; las adaptaciones (JWT, rutas REST,
normalización de errores) son propuestas para implementar en una fase posterior.*
