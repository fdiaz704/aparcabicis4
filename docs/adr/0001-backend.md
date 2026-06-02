# ADR 0001 — Backend de Aparcabicis

- **Estado:** Aceptado
- **Fecha:** 2026-06-02
- **Decisión:** API REST propia sobre **MariaDB** (relacional), hospedada en la UE, actuando como
  **capa de integración** sobre el sistema del fabricante del hardware de aparcamiento.

## Contexto

La app necesita una capa de red real para auth, estaciones, reservas en tiempo real, push y
cumplimiento GDPR/LOPD. La spec funcional pide explícitamente JWT, bcrypt, HTTPS, 2FA y push.

El dominio **no es CRUD simple**:

- El ciclo de vida de la reserva (`reserved → inUse → completed/expired`, con expiración de 30 min y
  máximo de uso de 14 h) debe ser **autoritativo en el servidor**, no en el cliente. Hoy
  `ReservationsProvider` corre `Timer.periodic` en el dispositivo, lo cual es incorrecto en
  producción (si el usuario cierra la app, la plaza no expira).
- "Abrir puerta" controla **hardware físico**, que ya gestiona un sistema del fabricante.

Se evaluaron tres opciones: API REST propia, Firebase y Supabase (ver *Alternativas*).

Cuatro factores del caso decidieron:

1. **Ya existe un sistema del fabricante** que abre puertas / reporta ocupación → el backend de la
   app es una **capa de integración**, no un sistema construido de cero.
2. **El equipo tiene capacidad backend** → REST propia es viable (cubre la pega principal: esfuerzo).
3. **Residencia de datos en UE estricta (legal/contractual)** → descarta Firebase (Auth no garantiza
   residencia UE); exige control de host y subprocesadores.
4. **Muchos usuarios con realtime → BD relacional predecible** → MariaDB, evitando el coste
   por-lectura de Firestore.

## Decisión

Construir una **API REST propia** (con el stack del equipo backend) sobre **MariaDB** en
infraestructura UE, como capa de integración delante del sistema del fabricante.

### Principios de diseño derivados del enlace con el fabricante

- **La ocupación/disponibilidad NO la reporta el fabricante.** Su API REST es **solo de comando**
  (abrir puerta), sin telemetría. Por tanto **nuestro backend es la fuente de verdad de la
  disponibilidad**, derivándola del estado de las reservas (`plazas libres = totales − reservas
  activas y en uso`). No hay sensor de ocupación físico que consultar.
- **La puerta se abre servidor → fabricante, nunca cliente → fabricante.** El cliente llama a
  nuestro backend; el backend habla con la API REST del fabricante (sus secretos, nuestra auditoría).
- **La transición `reserved → inUse` se confirma con el éxito de la llamada REST de apertura**, no
  con un evento de hardware (el fabricante no los emite). Si la apertura responde OK, el backend pasa
  a `inUse`; si falla, se mantiene `reserved` y se informa al cliente.
- **La expiración de 30 min y el límite de 14 h los posee en exclusiva el backend**, con dos
  mecanismos distintos según su naturaleza (ver *Planificador de expiración y sanción*). No hay
  estado de hardware contra el que reconciliar.

### Planificador de expiración y sanción

La expiración y el límite de 14 h **no son el mismo problema** y se implementan con mecanismos
distintos a propósito.

- **Expiración de reserva (30 min): Redis, como temporizador autoritativo del servidor.** Al crear
  la reserva se arma un contador en Redis; al vencer, dispara la **liberación de la plaza**
  (`reserved → expired`). Es el reloj autoritativo del backend (no del cliente). **Operativo hoy en
  Palma.**
- **Sanción por exceso (14 h): crontab, evaluada SOLO al desocupar la plaza.** El límite de 14 h
  **no** es un temporizador que salte a las 14 h ni vive en Redis. Es una **condición** que un job
  de **crontab** evalúa y aplica **después de que el usuario desocupa** la plaza.

  **Razón de diseño (explícita, intencional — no una limitación pendiente):** sancionar
  automáticamente al cumplirse las 14 h con el VMP aún dentro **no liberaría la plaza** — seguiría
  bloqueada para otros usuarios. Disparar una acción al cumplirse el contador no resuelve nada físico.
  Por eso el límite de 14 h se modela como una **condición evaluada en el momento de la liberación**,
  no como un temporizador que dispara una acción.

#### Redis es parte del stack POR CIUDAD

Coherente con el [ADR 0002](0002-multi-ciudad.md) (despliegue por ciudad, multi-tenant por BD),
**Redis forma parte del stack estándar de cada ciudad**: cada despliegue tendrá su **propia
instancia de Redis**, gestionada igual y aislada como el resto de su configuración. La cadena de
conexión a Redis es **config por despliegue**, no código. Hoy solo existe la instancia de **Palma**
por ser la ciudad de v1.

## Consecuencias

### Implicación principal: los atajos atados a Postgres ya no aplican

La elección anterior contemplaba componentes que **requieren Postgres**. Con MariaDB quedan
descartados y se sustituyen:

| Atajo Postgres descartado | Por qué | Sustituto en MariaDB |
| --- | --- | --- |
| `LISTEN/NOTIFY` para realtime | Es específico de Postgres | **WebSocket/SSE desde el backend** (cuando se necesite realtime) |
| `pg_cron` para expirar reservas | Extensión de Postgres | **Redis** (temporizador autoritativo para la expiración de 30 min) **+ crontab** (evaluación de la sanción de 14 h en la liberación). Ver *Planificador de expiración y sanción* |
| **GoTrue self-hosted** para auth (bcrypt+JWT+MFA) | GoTrue requiere Postgres | **Librería madura del stack backend**: hashing **bcrypt/argon2** + **JWT** + 2FA (TOTP) implementados en el backend |

### El realtime es prácticamente nulo hoy

Confirmado: la API del fabricante es **REST de solo comando** y **no reporta apertura de puerta ni
ocupación**. El enlace es unidireccional. Los únicos cambios de disponibilidad son los que genera la
propia app (reservas de otros usuarios), y el backend ya los conoce. Por tanto:

- **No se construye infraestructura realtime** (ni `LISTEN/NOTIFY`, ni WebSocket/SSE) por ahora;
  perder `LISTEN/NOTIFY` no penaliza el caso actual.
- La lista de estaciones se refresca por **polling** en el cliente; basta para reflejar reservas de
  otros usuarios.
- El WebSocket/SSE queda como ampliación futura **solo si** el fabricante llegara a ofrecer
  telemetría de ocupación.

### Riesgo asumido: sin reconciliación con la realidad física

Como el fabricante no reporta ocupación ni aperturas, la disponibilidad que muestra la app es un
**modelo derivado de las reservas**, no una lectura del mundo físico. Si alguien aparca sin reservar,
fuerza una puerta o el hardware difiere, el backend **no se entera**. Se asume este riesgo dado el
enlace actual; las mitigaciones (auditoría de comandos de apertura, conciliación periódica) solo son
posibles si el fabricante añade telemetría, y quedan fuera de alcance hasta entonces.

### Motor de base de datos

Se asume **InnoDB** como motor de tablas: aporta **transacciones** e **integridad referencial**,
necesarias para la lógica de reservas (crear/cancelar/expirar de forma atómica, claves foráneas
usuario↔reserva↔estación). No usar MyISAM.

### Cumplimiento (GDPR/LOPD)

- Residencia UE total: host y MariaDB en región UE; un único DPA con el hosting; sin subprocesadores
  fuera de la UE para datos personales.
- Contraseñas con bcrypt/argon2; comunicación HTTPS; tokens JWT con expiración + refresh.
- La eliminación de cuenta y la retención de datos se implementan en el backend (la app ya tiene la
  pantalla de borrado de cuenta).

### Push

El lado cliente es **FCM/APNs** independientemente del backend (mismo `firebase_messaging` en
Flutter). El backend envía vía FCM Admin / APNs. No introduce dependencia de plataforma de backend.

### Impacto en los providers Flutter (resumen; ver tarea de implementación)

- Introducir una **capa de repositorio** (`AuthRepository`, `StationsRepository`,
  `ReservationsRepository`) entre los `ChangeNotifier` y la red; añadir estados `loading/error`.
- `AuthProvider`: llamadas a `/auth/*`; JWT + refresh en `SecureStorageService` (ya encaminado);
  paso de 2FA.
- `StationsProvider`: estaciones y **disponibilidad derivada** desde nuestro backend; refresco por
  **polling** (no hay telemetría de ocupación del fabricante que hacer proxy).
- `ReservationsProvider`: eliminar `Timer.periodic` como fuente de verdad; cuenta atrás derivada de
  timestamps del servidor; `createReservation/openDoor/cancel/finish` remotos; estado confirmado por
  el backend/fabricante.

## Alternativas consideradas

- **Firebase (Auth + Firestore + Functions + FCM).** Rechazada: **Firebase Authentication no
  garantiza residencia de datos en UE** (choca con el requisito legal estricto), no usa bcrypt
  (scrypt) y la MFA queda en Identity Platform de pago; además, alto lock-in y coste por-lectura de
  Firestore con realtime.
- **Supabase (Postgres + GoTrue + Realtime + Edge Functions).** Rechazada como plataforma: encajaba
  bien en seguridad (bcrypt+JWT+MFA) y UE, pero (a) la BD corporativa es **MariaDB**, no Postgres, lo
  que invalida sus piezas clave (GoTrue, Realtime sobre Postgres), y (b) ya existe equipo backend y
  un sistema del fabricante que extender, lo que hace preferible el control de una REST propia.

## Resuelto

- **Qué expone el sistema del fabricante:** API **REST de solo comando** (abrir puerta). **No**
  reporta apertura de puerta ni ocupación. Enlace **unidireccional** → máquina de estados
  *command-response* (no event-driven), disponibilidad derivada por nuestro backend, realtime
  diferido.

## Pendiente

- Próximos artefactos: **contrato de API + modelo de datos MariaDB** (incluida la integración REST
  *command-only* con el fabricante) y **esqueleto de la capa de red** en Flutter.
- Detalles del comando de apertura del fabricante: **autenticación, idempotencia, timeouts y manejo
  de error** (qué hacer si la apertura no responde o falla a medias).
