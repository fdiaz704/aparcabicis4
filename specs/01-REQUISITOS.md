# 01 — Requisitos

Prioridad: **M** = imprescindible v1 · **S** = deseable v1 · **C** = futuro.

## 1. Requisitos funcionales

### RF-0 Multi-ciudad (flavors) — [Req. usuario #1]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-0.1 | Un flavor por ciudad (Android productFlavors + iOS schemes, seleccionado con `--dart-define=CITY=<slug>`) | M |
| RF-0.2 | Config por ciudad en `lib/config/cities/<slug>.dart`: nombre, apiBaseUrl, cityId, centro/zoom del mapa, branding (logo/colores), IDs de tienda, URLs de términos y privacidad, idiomas | M |
| RF-0.3 | Cero referencias a una ciudad concreta fuera de la config del flavor (los 8 parkings de Madrid pasan a ser seed del flavor demo) | M |
| RF-0.4 | Un binario por ciudad publicable en tiendas con applicationId/bundleId propio | M |

### RF-A Arranque y versión — [Req. #2]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-A.1 | En el splash, comparar versión instalada (package_info_plus) con la última publicada en tiendas (paquete `upgrader`: iTunes Lookup en iOS, Play en Android) | M |
| RF-A.2 | Comprobación de versión vía backend: `POST /check_version` con `{platform, version_code, build_number}` devuelve `{latest_version, latest_build, force_update, url, client_known}` (fuente de verdad si la lectura de tienda falla) | M |
| RF-A.3 | Si hay versión más reciente ⇒ pantalla bloqueante no descartable con botón "Actualizar" que abre la tienda; el usuario no puede continuar | M |
| RF-A.4 | Si la comprobación falla (sin red, tienda no responde) ⇒ la app continúa y reintenta en el siguiente arranque (no bloquear por un fallo de la comprobación) | M |

### RF-1 Autenticación — [Req. #3]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-1.1 | Registro con email + contraseña (≥8 caracteres, validación de formato) contra la API | M |
| RF-1.2 | Login con email + contraseña; la API devuelve JWT (access + refresh) | M |
| RF-1.3 | Tokens en almacenamiento seguro (flutter_secure_storage); nunca contraseña persistida | M |
| RF-1.4 | Renovación silenciosa del access token con refresh token | M |
| RF-1.5 | Recuperación de contraseña por email (token de un solo uso) | M |
| RF-1.6 | **Biometría**: al activar "Recuérdame" se solicita habilitar biometría (local_auth). Desde entonces la sesión se restaura con huella/Face ID; fallback a contraseña si falla o el dispositivo no la soporta | M |
| RF-1.7 | Cambio de contraseña y eliminación de cuenta: FUERA del UI v1 (req. #11); los endpoints quedan en el contrato como opcionales | C |

### RF-B Bootstrap de sesión — [Req. #4]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-B.1 | Tras login (o restauración de sesión), `GET /bootstrap` devuelve en una sola llamada: perfil del usuario, parámetros del sistema, estadísticas de uso del usuario y **uso actual** (reserva `pending`/`active` o null) | M |
| RF-B.2 | Parámetros del sistema servidos por el backend (tabla de configuración, req. #5-7): ventana de reserva, tiempo máximo de uso, offsets de avisos. Nada de tiempos hardcodeados en la app | M |
| RF-B.3 | Si hay uso actual, la app navega directamente a la pantalla de reserva/uso activo y **bloquea nuevas reservas** hasta desocupar (regla también en backend: 409) | M |

### RF-2 Mapa y aparcamientos — [Req. #5]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-2.1 | Listado de aparcamientos de la ciudad del flavor desde la API; refresco por polling cada 30 s | M |
| RF-2.2 | **Markers personalizados** (asset propio, no pin de Google) coloreados por **disponibilidad** (`availabilityRate = libres/totales`): verde ≥60 % libre · amarillo ≥20 % y <60 % libre · rojo <20 % libre | M |
| RF-2.3 | Zoom in/out por gestos táctiles (pinch y doble toque) | M |
| RF-2.4 | Botón "mi ubicación": geolocalización real (geolocator + permission_handler) y centrado del mapa; gestión de permiso denegado | M |
| RF-2.5 | Panel/lista de aparcamientos **más cercanos** a la posición del usuario, ordenados por distancia | M |
| RF-2.6 | Al elegir uno: trazar **ruta** en el mapa (polyline, Google Directions API) con ETA; si ETA > tiempo de ventana de reserva restante, avisar antes de confirmar la reserva | M |
| RF-2.7 | Búsqueda por texto, filtros (disponibles/favoritos) y ordenación por nombre, disponibilidad o distancia | M |
| RF-2.8 | Favoritos sincronizados con el backend | S |

### RF-3 Reserva: cuenta atrás y vencimiento — [Req. #6]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-3.1 | Crear reserva ⇒ cuenta atrás visual sincronizada con `expiresAt` del servidor | M |
| RF-3.2 | Una sola reserva/uso activo por usuario (backend 409 + UI) | M |
| RF-3.3 | Aviso a **10 min** y a **5 min** del vencimiento: notificación local + banner in-app ("tu reserva vence en X min") | M |
| RF-3.4 | Al vencer: notificación local "tu reserva ha vencido", la app confirma la liberación contra la API (el backend ya la expira por job; la app sincroniza con `GET /reservations/current`) y navega a la pantalla del mapa | M |
| RF-3.5 | Cancelación manual antes del check-in | M |
| RF-3.6 | Estados: `pending` → `active` (check-in) → `completed` / `cancelled` / `expired` | M |

### RF-4 Control de acceso y uso — [Req. #7]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-4.1 | Botón "Abrir puerta" activo solo con reserva `pending` (check-in) o `active` (recogida) | M |
| RF-4.2 | `POST /reservations/{id}/open`: el backend valida y ordena la apertura a la pasarela hardware; resultado `opened`/`failed`/`timeout` en <5 s | M |
| RF-4.3 | Primer open exitoso ⇒ check-in: comienza la cuenta de **tiempo máximo de uso** (`maxUntil`, parámetro de la tabla de configuración) | M |
| RF-4.4 | Avisos de fin de uso por notificación local: a **30 min**, **15 min** y **5 min** de `maxUntil`; superado el tiempo, aviso **cada 30 min** (serie programada localmente, funciona con la app cerrada) | M |
| RF-4.5 | Open durante `active` + confirmación "he retirado mi vehículo" ⇒ checkout (`completed`), cancela avisos pendientes | M |
| RF-4.6 | Auditoría de toda apertura en backend (`access_events`) | M |
| RF-4.7 | Modo degradado si la pasarela no responde: mensaje + teléfono de soporte | M |

### RF-5 Historial y perfil — [Req. #8]
| ID | Requisito | Prioridad |
|---|---|---|
| RF-5.1 | Historial desde la API (JSON): toda la actividad del usuario de los **últimos 3 meses**, paginado, con caché 