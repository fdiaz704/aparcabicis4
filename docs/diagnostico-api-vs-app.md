# Diagnóstico — API existente vs. funcionalidades de la app AparcaBicis

- **Fecha:** 2026-06-02
- **Modo:** SOLO LECTURA sobre la API (`C:\Users\fdiaz\repos\api`). No se ha modificado
  ningún endpoint ni tabla. Este documento solo analiza y propone.
- **Fuentes analizadas:**
  - API REST PHP en `repos/api` (código real de cada endpoint y sus consultas SQL).
  - App Flutter `aparcabicis4` (`lib/`, `docs/API.md`).
  - `docs/adr/0001-backend.md` (decisión de arquitectura).
- **Alcance:** decidir, para cada funcionalidad de la app, si la API y el esquema de tablas
  actuales **la cubren**, **requieren modificación**, o **no se pueden cerrar por falta de
  información**. Las funcionalidades que dependen de datos que el hardware no proporciona se
  marcan explícitamente.

---

## 0. Confirmación: ¿es esta la API de AparcaBicis?

**Sí, es la API de AparcaBicis** (no es la del SAE ni otro proyecto). Evidencias en el código:

- El `README.md` de la API se titula `aparcabicis-backend` y declara que da servicio a "la app
  móvil **aparcabicis4** y al panel de control web".
- La base de datos es **`palma`** y el dominio es de **plazas de aparcamiento de bicicletas en
  lockers**: tablas `PLAZAS`, `API_usr`, `DATALOG`, `LOG_SESIONES`, `usuarios_bici`,
  `log_estado_usuarios`. Los textos hablan de "Biciespai Palma", "biciparking", "locker".
- El ciclo de vida coincide con el de la app: reservar plaza → abrir puerta → finalizar uso, con
  estados `pla_status` 0/1/2 (libre/reservada/ocupada) y caducidad de reserva a 30 min.

**Matiz importante sobre el estilo / el aviso del SAE.** Dentro del mismo repositorio conviven
**dos estilos de código distintos**:

1. **El núcleo de AparcaBicis** (`reserva`, `apertura`, `end_sesion`, `info_plazas`, `info_usr`,
   `token`, …): patrón "una carpeta por endpoint" con `index.php` + manejador + `clases/auth.class.php`,
   respuestas `{status, result}`, autenticación por `UsrAPI`/`APIkey`. **Este es el patrón propio de
   AparcaBicis** y es el que debe guiar el diseño nuevo, alineado con el ADR.
2. **El módulo `rutas_servicio`**: es de **otro dominio** (rutas de servicio/transporte: consulta una
   geometría `trayecto` con `ST_AsGeoJSON` por `nombre_ruta` tipo `LUNES-VIERNES`). Usa un estilo
   diferente y más moderno (namespace `Aparcabicis\`, `lib/Conexion.php`, `lib/Respuestas.php`,
   respuestas `ok()`). **No es funcionalidad de la app de aparcamiento** y **no debe tomarse como
   referencia de estilo** para AparcaBicis, en línea con tu instrucción. Lo menciono solo para que
   conste que está ahí y que es ajeno al alcance de esta app.

---

## 1. Qué expone hoy la API (caracterización)

### 1.1. Modelo de autenticación (clave para entender las brechas)

La API **autentica al cliente (la app como sistema), no al usuario final**. Cada petición lleva:

- `UsrAPI` + `APIkey`: credenciales del **cliente API**, validadas contra la tabla `API_usr`
  (`API_KEY` es un token rotatorio que el endpoint `token` regenera con `bin2hex(openssl_random…)`
  a partir de la contraseña `Pasword` del cliente). Es autenticación **de aplicación**, no de persona.
- `IDusrAPP`: identificador del usuario final (en la práctica, su **correo**). **La API lo recibe y
  lo propaga, pero NO lo verifica**: no hay contraseña de usuario final, ni comprobación de identidad,
  ni sesión de usuario. Quien tenga `UsrAPI`/`APIkey` puede operar en nombre de cualquier `IDusrAPP`.

**Consecuencia:** todo el módulo de cuentas de la app (registro, login, cambio de contraseña,
recuperación, borrado de cuenta) **no tiene contraparte en la API**. Ver sección 2.1.

### 1.2. Endpoints existentes (los relevantes para la app)

| Endpoint | Método | Entrada (además de UsrAPI/APIkey) | Qué hace |
|---|---|---|---|
| `token` | POST | `psw` | Regenera y devuelve el `API_KEY` del cliente API. Auth de aplicación. |
| `reserva` | POST | `IDlocker`, `IDusrAPP`, `Tipo_lock` | Reserva una plaza libre dentro de un locker (autoselección + reintento anti-carrera). Pone `pla_status=1`, caduca a +30 min. Devuelve `IDspace`, `Time`, `EndTime`. **No devuelve `session_id`** (decisión cerrada). |
| `apertura` | POST | `IDlocker`, `IDspace`, `IDusrAPP`, `trigger` | Abre la puerta llamando por cURL a `pla_url` del hardware. `trigger=0` primera apertura (`pla_status`→2), `trigger=1` aperturas sucesivas. Confirma con el HTTP code del hardware. |
| `end_sesion` | POST | `IDlocker`, `IDspace`, `IDusrAPP`, `Locksensor` | Cancela reserva (si estaba en `1`) o finaliza uso (si estaba en `2`). Libera la plaza (`pla_status=0`). |
| `info_plazas` | POST | `IDlocker` | Devuelve **contadores** `free`/`reserved`/`occupied` de **un** locker. |
| `info_usr` | POST | `IDusrAPP` | Estado de la reserva/uso **del usuario** (si tiene plaza reservada o en uso, locker, espacio, caducidad). |
| `info_token` | POST | — | Información del token. |
| `check_inact_user` | POST | `correo` | Lógica de **sanción**: si el uso superó 14 h, inactiva al usuario en `usuarios_bici` y le envía email. |
| `users/deactivate`, `apertura_admin`, `end_sesion_admin`, `end_sesion_vR`, `block_admin` | POST | — | Variantes administrativas / de mantenimiento. No son flujo de la app de usuario. |
| `sensado_puertas/mysql.php` | GET | `pla_id`, `pla_apbid`, `pla_puerta_st` | **Ingesta** del sensor físico de puerta: un sistema "Control" escribe `pla_puerta_st` en `PLAZAS`. |

### 1.3. Esquema de `PLAZAS` (deducido de las consultas)

Columnas que el código usa: `pla_id` (espacio), `pla_apbid` (locker), `pla_status` (0/1/2),
`pla_elect` (tipo: 0 sin enchufe / 1 con enchufe / 2 indistinto), `pla_usuario` (= `IDusrAPP`),
`pla_vctoreserv` (caducidad reserva), `session_id`, `reserved_at`, `opened_at`, `opened_via`,
`closed_at`, `closed_via`, `pla_updatetime`, `pla_url` (endpoint del hardware), `pla_maintenance`
(contador de aperturas), `pla_puerta_st` (sensor de puerta).

**No existe en `PLAZAS` (ni en ninguna tabla vista):** nombre de estación, dirección, **latitud /
longitud**, capacidad total como atributo, ni un catálogo de estaciones consultable como lista.
La "estación" hoy es implícita: el `IDlocker` (`pla_apbid`) agrupa filas de `PLAZAS`.

---

## 2. Recorrido funcional de la app

Leyenda de estado:

- 🟢 **Cubierta** — la API y el esquema actuales la soportan (quizá con adaptación menor del contrato).
- 🟡 **Requiere modificación** — hace falta crear/cambiar endpoint o tabla; el cambio está claro.
- 🔴 **Falta información** — no se puede cerrar el diseño hasta que aportes una decisión/dato.
- ⛔ **Dependiente de hardware** — depende de datos que el hardware hoy no proporciona (ver sección 3).

### 2.1. Autenticación y gestión de usuarios (app §4.1)

| Funcionalidad de la app | Estado | Diagnóstico |
|---|---|---|
| **Login** de usuario (`AuthProvider.login`) | 🔴🟡 | **No hay endpoint de login de usuario final.** La API solo autentica al cliente (`token`). No existe almacén de contraseñas de usuario (la tabla `usuarios_bici` tiene `correo`, `activo`, `inactivohasta`… **pero no se observa columna de contraseña/hash**). Hay que **crear** `POST /auth/login` + almacenamiento de credenciales con bcrypt/argon2 (como pide el ADR). **Falta info:** ver bloque de decisiones (¿identidad propia con contraseña? ¿verificación de email? ¿2FA del ADR en v1 o diferido?). |
| **Registro** (`createUser`) | 🔴🟡 | No existe. Hay que crear `POST /auth/register` y una tabla de identidad de usuario con hash de contraseña. Hoy `usuarios_bici` parece poblarse por el flujo operativo, no por un alta con credenciales. **Falta info:** política de alta (¿auto-registro abierto? ¿verificación por email obligatoria? ¿unicidad por `correo`?). |
| **Cambio de contraseña** (`changePassword`) | 🔴🟡 | No existe. Depende de que exista identidad con contraseña. Crear `PUT /auth/password` (autenticado), validando la actual. |
| **Recuperación de contraseña** (`sendPasswordResetEmail`) | 🟡 | No existe como endpoint, pero **la infraestructura de email ya está** (PHPMailer + SMTP configurado en `check_inact_user`). Hay que crear `POST /auth/password/reset` (token de un solo uso + email). **Falta info:** proveedor/credenciales SMTP "oficiales" para producción (las actuales están hardcodeadas y son de pruebas). |
| **Eliminación de cuenta** (`deleteUser`) | 🔴🟡 | No existe para el usuario final. Existe `users/deactivate` y la lógica de inactivación, pero es **sanción/baja administrativa**, no "borrado de cuenta a petición del usuario" (GDPR). Hay que crear `DELETE /auth/account` con borrado/anonimización real. **Falta info:** política de retención (¿borrado físico, anonimización, plazo legal de conservación de logs `DATALOG`/`LOG_SESIONES`?). |

> **Nota transversal de seguridad (informativa, no bloqueante para el diagnóstico):** varios endpoints
> legacy concatenan SQL directamente (`info_usr`, `info_plazas`, `token`, `sensado_puertas`) y hay
> credenciales de BD y SMTP en claro en el repo (`sensado_puertas/mysql.php`, `check_inact_user`). El
> ADR ya exige bcrypt/JWT/HTTPS; conviene cerrarlo al diseñar el módulo de auth. Lo dejo señalado pero
> fuera del alcance funcional pedido.

### 2.2. Estaciones / aparcamientos (app §4.2)

| Funcionalidad de la app | Estado | Diagnóstico |
|---|---|---|
| **Listar estaciones** (`GET /api/stations` propuesto) | 🔴🟡 ⛔(parcial) | **No hay endpoint que devuelva la lista de estaciones.** `info_plazas` solo da contadores de **un** locker pasando `IDlocker`. Además, **el esquema no tiene nombre, dirección ni lat/lng**, que el modelo `BikeStation` necesita para la lista y el mapa. Hay que: (a) **crear tabla/columnas de catálogo de estación** (nombre, dirección, lat, lng, total) y (b) **crear** `GET /stations` que agregue plazas por locker + disponibilidad derivada. **Falta info:** de dónde salen nombre/dirección/coordenadas de cada locker (ver decisiones). |
| **Obtener estación por id** | 🟡 | Derivable una vez exista el catálogo + endpoint de lista. Crear `GET /stations/{id}`. |
| **Disponibilidad de plazas** (libres/ocupadas) | 🟢⛔ | **Cubierta a nivel de datos**: `info_plazas` ya calcula `free/reserved/occupied` desde `pla_status`, que es exactamente la "disponibilidad derivada" que define el ADR. Limitaciones: es **un locker por llamada** (no lista) y **no refleja ocupación física no reservada** (ver sección 3). Para la app hace falta exponerla por estación dentro del `GET /stations`. |
| **Marcar/Desmarcar favorito** | 🟡 (o se queda local) | Hoy es 100% local (`SharedPreferences`). No hay endpoint ni tabla. **Decisión tuya:** ¿los favoritos deben sincronizarse entre dispositivos (→ tabla `favoritos` + endpoints `POST/DELETE /stations/{id}/favorite`, requiere identidad de usuario) o se mantienen locales en el dispositivo (→ sin cambios en la API)? |
| **Marcadores verde/amarillo/rojo del mapa** | 🔴⛔ | Ver sección 3. Depende de (a) coordenadas inexistentes en el esquema y (b) un criterio de umbrales que no está definido. |

### 2.3. Reservas (app §4.3)

| Funcionalidad de la app | Estado | Diagnóstico |
|---|---|---|
| **Crear reserva** (`createReservation`) | 🟢🟡 | **Cubierta** por `reserva`. Ajustes de contrato: la app hoy reserva pasando un `BikeStation` y decide en local; la API reserva por `IDlocker` + `Tipo_lock` y **autoselecciona** el espacio. Hay que: alinear el cuerpo (la app deberá enviar `IDlocker` y, si aplica, `Tipo_lock`) y consumir el `IDspace` que devuelve la API (lo necesita para abrir puerta). El bloqueo anti-carrera ya está resuelto en el servidor (Solución A). **Falta info menor:** ¿la app debe exponer el filtro de plaza con/sin enchufe (`Tipo_lock` 0/1/2)? Hoy el modelo Flutter no lo contempla. |
| **Abrir puerta** (`openDoor`) | 🟢🟡 | **Cubierta** por `apertura` (`trigger=0` primera vez → pasa a *en uso*; `trigger=1` siguientes). En la app hoy `openDoor()` es solo un cambio de estado local sin red; hay que cablearlo al endpoint. La transición `reserved→inUse` y su confirmación las decide el servidor con el HTTP code del hardware, **tal como define el ADR**. |
| **Cancelar reserva / Finalizar uso** | 🟢🟡 | **Cubierta** por `end_sesion` (distingue cancelación de reserva vs. cierre de uso según `pla_status`). Ajuste de contrato: la app envía un parámetro `Locksensor`; hay que definir qué valor manda y cuándo (ver matiz del sensor en sección 3). |
| **Expiración automática (30 min) y máx. de uso (14 h)** | 🟡 ⛔(reconciliación) | El ADR exige que la expiración sea **autoritativa en el servidor** (scheduler / Event Scheduler de MariaDB). Hoy: la caducidad de reserva se **graba** (`pla_vctoreserv = +30min`) pero **no se ha visto un proceso servidor que libere automáticamente** las reservas caducadas; la app lo hace con `Timer.periodic` (incorrecto en producción, como reconoce el ADR). La sanción por exceso de 14 h sí existe (`check_inact_user`) pero **se dispara por invocación**, no se ha visto su planificador. **Falta info:** ¿existe ya un cron/Event Scheduler que llame a estos procesos? Si no, hay que crearlo. |
| **Historial de reservas** | 🔴🟡 | **No hay endpoint de lectura de historial.** La app lo guarda local (`SharedPreferences`). Los datos existen parcialmente en `LOG_SESIONES` (eventos `session.reserved/opened/closed/...`) y `DATALOG`, pero no hay consulta que los devuelva como historial del usuario. Hay que crear `GET /reservations` (historial por `IDusrAPP`). **Falta info:** ¿el historial debe ser autoritativo del servidor (multi-dispositivo) o seguir siendo local? Si servidor, ¿se reconstruye desde `LOG_SESIONES` o se crea una tabla de historial propia? |
| **Estadísticas** (`getStatistics`, ahorro, tasas…) | 🔴🟡 | Sin endpoint; todo se calcula en local sobre el historial local. Si el historial pasa a servidor, las stats se derivan ahí (`GET /reservations/stats`). **Falta info:** definición de métricas "de negocio" (p. ej. el "ahorro" hoy asume 2 €/h inventados; ¿hay tarifa real?). |

### 2.4. Otras pantallas / servicios

| Funcionalidad | Estado | Diagnóstico |
|---|---|---|
| **Reserva activa** (pantalla con cuenta atrás + mapa) | 🟢🟡 | El estado vivo de la reserva del usuario lo da `info_usr` (locker, espacio, caducidad, en reserva/en uso). Cubre la cuenta atrás si la app la deriva de los **timestamps del servidor** (como pide el ADR) en vez de su `Timer` local. El mapa de esa pantalla depende de coordenadas (ver 2.2/sección 3). |
| **Ayuda / teléfono de soporte** | 🟢 | No es API: `url_launcher` a `tel:`. Sin impacto en backend. |
| **Google Maps (render)** | 🟢 | Servicio externo con API key; no es la API propia. Solo necesita que la API le dé coordenadas (que hoy no tiene). |
| **Push (FCM/APNs)** | 🔴 | El ADR lo contempla en cliente; el backend tendría que enviar (avisos de 5 min, expiración, sanción). Hoy no hay nada de push en la API. **Falta info:** ¿entra en este alcance o se difiere? Si entra, hay que registrar tokens de dispositivo (tabla nueva) y definir los disparadores. |

---

## 3. ⛔ Funcionalidades que dependen de datos que el hardware hoy NO proporciona

Esta es la sección que pediste marcar de forma especial. El ADR fija que **el enlace con el hardware
es unidireccional y de solo comando** (abrir puerta), sin telemetría de ocupación. El código confirma
casi todo eso, **con una excepción importante que debes resolver**.

### 3.1. Disponibilidad / ocupación en tiempo real

- **Lo que hay:** disponibilidad **derivada de las reservas** (`free/reserved/occupied` por
  `pla_status` en `info_plazas`). Es el modelo que el ADR asume como fuente de verdad.
- **Lo que NO hay:** lectura física de ocupación. Si alguien aparca sin reservar, fuerza una puerta o
  el hardware difiere, **el backend no se entera** (riesgo ya asumido en el ADR).
- **Para la app:** la "disponibilidad en tiempo real" se reduce a **polling** del `GET /stations`
  (sin WebSocket/SSE), tal como decide el ADR. No es realtime físico, es realtime de reservas.

### 3.2. Confirmación de apertura de puerta

- **Matiz clave:** existe **confirmación a nivel de command-response**, no de evento de hardware. El
  endpoint `apertura` llama por cURL a `pla_url` y **usa el HTTP code** para decidir éxito
  (`session.opened`) o fallo (`session.open_failed`, con `HARDWARE_TIMEOUT`/`HARDWARE_ERROR`). Es
  decir: la app **sí puede saber si la orden de abrir fue aceptada por el hardware**, que es justo lo
  que el ADR define como criterio para `reserved→inUse`.
- **Lo que NO hay (según el ADR):** un evento asíncrono "la puerta se abrió/cerró físicamente"
  independiente de la respuesta a la orden.

### 3.3. ⚠️ Discrepancia ADR ↔ código: el sensor de puerta `pla_puerta_st`

**Esto necesita una decisión tuya.** El ADR afirma que el hardware **no reporta telemetría**. Pero en
el código sí aparece un canal de telemetría de puerta:

- Existe la columna `PLAZAS.pla_puerta_st` y el endpoint `sensado_puertas/mysql.php`, por el que un
  sistema externo ("Control") **escribe el estado físico de la puerta** (abierta=1 / cerrada=0) vía GET.
- `end_sesion` **lo consume**: si la app envía `Locksensor=1` y la puerta está abierta
  (`pla_puerta_st != 0`), **rechaza la liberación** con "Puerta abierta".

Por tanto, **en el sistema sí hay una señal de puerta física**, al menos para algunas plazas. Esto
contradice (o matiza) el supuesto del ADR de "cero telemetría". **Decisión necesaria:** ¿`pla_puerta_st`
es fiable y está disponible para todas las plazas que usará la app? Según la respuesta:

- Si **sí es fiable** → la app podría mostrar estado real de puerta y ocupación más veraz; habría que
  revisar el ADR (su premisa "unidireccional puro" no se sostiene del todo).
- Si **no es fiable / es de otro subsistema** → mantener el enfoque del ADR (disponibilidad derivada) y
  documentar que `pla_puerta_st` no se expone a la app.

### 3.4. Marcadores verde / amarillo / rojo del mapa

Esta funcionalidad **está doblemente bloqueada**:

1. **Faltan coordenadas (🔴 dato inexistente):** el esquema no tiene lat/lng/nombre/dirección por
   locker. Sin eso no se pueden colocar marcadores. Requiere catálogo de estaciones (sección 2.2).
2. **Falta el criterio de color (🔴 decisión):** "verde/amarillo/rojo" no está definido. Los datos
   disponibles (`free/reserved/occupied`) permiten calcularlo, pero hay que fijar los umbrales.
   Además, `AppColors` de la app hoy define verde/rojo/**azul (reservado)**, no amarillo, así que
   también hay un desajuste entre la paleta del código y el verde/amarillo/rojo de la especificación.

**Decisión necesaria:** la regla exacta de color. Ejemplo a validar (no es una recomendación, es una
plantilla para que decidas): verde = `free > N`; amarillo = `0 < free ≤ N`; rojo = `free == 0`. ¿Cuál
es `N`? ¿Se calcula por número absoluto o por porcentaje del total del locker?

---

## 4. Qué necesito de ti para poder diseñar (lista consolidada de decisiones)

Ordenadas por impacto en el diseño:

1. **Identidad del usuario final.** ¿La app tendrá identidad propia con contraseña gestionada por
   nuestro backend (bcrypt/argon2 + JWT, como dice el ADR)? Hoy la API **no autentica usuarios**, solo
   clientes. Necesito confirmar el modelo: tabla de usuarios con hash, verificación de email sí/no,
   2FA (TOTP) en v1 o diferida.
2. **Catálogo y geolocalización de estaciones.** ¿De dónde salen nombre, dirección, **latitud y
   longitud** y capacidad total de cada locker (`pla_apbid`)? No están en la BD. ¿Hay una hoja/fuente
   maestra para cargarlos, o se introducen a mano? Esto desbloquea lista de estaciones, mapa y
   marcadores.
3. **Regla de los marcadores verde/amarillo/rojo.** Umbrales exactos y si son absolutos o porcentuales.
   Y confirmar que la paleta pasa a verde/amarillo/rojo (la app hoy usa verde/rojo/azul).
4. **Sensor de puerta `pla_puerta_st`.** ¿Es fiable y universal? De su respuesta depende si revisamos
   la premisa "unidireccional" del ADR o lo dejamos como canal interno no expuesto a la app.
5. **Tipo de plaza (`Tipo_lock`/`pla_elect`: con/sin enchufe).** ¿La app debe permitir al usuario
   elegir plaza con enchufe? Si sí, hay que añadirlo al modelo y a la pantalla de reserva.
6. **Favoritos.** ¿Locales por dispositivo (sin backend) o sincronizados (tabla + endpoints, requiere
   identidad de usuario)?
7. **Historial y estadísticas.** ¿Autoritativos del servidor (multi-dispositivo) o locales? Si
   servidor: ¿reconstruir desde `LOG_SESIONES` o tabla de historial nueva? Y definición de métricas
   "de negocio" (p. ej. tarifa real para el "ahorro").
8. **Expiración/sanción automáticas.** ¿Existe ya un cron / Event Scheduler que libere reservas
   caducadas (30 min) y dispare la sanción de 14 h, o hay que crearlo? El ADR exige que sea
   autoritativo del servidor.
9. **Borrado de cuenta (GDPR).** Política de retención: ¿borrado físico, anonimización, plazo de
   conservación de `DATALOG`/`LOG_SESIONES`?
10. **Push (FCM/APNs).** ¿Entra en este alcance? Si sí, hay que registrar tokens de dispositivo y
    definir disparadores (aviso 5 min, expiración, sanción).
11. **SMTP de producción** para los emails (recuperación de contraseña, avisos). Las credenciales
    actuales del repo son de pruebas y están en claro.

---

## 5. Resumen por estado

| Estado | Funcionalidades |
|---|---|
| 🟢 **Cubierta** (con cableado/ajuste de contrato) | Crear reserva, Abrir puerta, Cancelar/Finalizar, Disponibilidad por locker (derivada), Estado de reserva activa del usuario (`info_usr`), Ayuda/teléfono, Render de mapa |
| 🟡 **Requiere modificación** (cambio claro) | Recuperación de contraseña, Obtener estación por id, alineación de contrato de reserva/end_sesion, planificador de expiración/sanción |
| 🔴 **Falta información / decisión** | Login, Registro, Cambio de contraseña, Borrado de cuenta, Lista de estaciones + catálogo, Historial, Estadísticas, Favoritos (modelo), Push |
| ⛔ **Dependiente de datos de hardware** | Ocupación física en tiempo real (no existe), Confirmación de apertura (sí, a nivel command-response), **Marcadores verde/amarillo/rojo** (bloqueados por coordenadas + criterio), interpretación de `pla_puerta_st` |

---

*No se ha modificado ningún endpoint ni tabla de la API. Este documento es solo análisis y propuesta;
cualquier cambio sobre endpoints o esquema se te presentará antes de aplicarlo.*
