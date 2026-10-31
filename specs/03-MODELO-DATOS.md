# 03 — Modelo de datos

Esquema **MySQL / MariaDB** (backend LAMP). Los modelos Dart de la app son proyecciones de estas entidades (solo los campos que la UI necesita).

> **Convenciones MySQL/MariaDB.** Motor **InnoDB**, charset **utf8mb4**. Las claves primarias `id` son `CHAR(36)` (UUID en texto; alternativa `BINARY(16)` si se prefiere compacidad). Las marcas de tiempo son `DATETIME(6)` almacenadas en **UTC**. Los booleanos son `TINYINT(1)`. Las listas (offsets de aviso, tipos admitidos, fotos, puertas) se guardan en el tipo **`JSON`** nativo. MySQL/MariaDB no soporta índices parciales: la regla "una sola reserva activa por usuario" se emula con **columna generada + índice `UNIQUE`** (ver `reservations`).

## cities (multi-ciudad, req. #1)
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | CHAR(36) PK | |
| slug | VARCHAR(50) UNIQUE NOT NULL | coincide con el flavor (`valencia`, `demo`…) |
| name | VARCHAR(120) NOT NULL | mostrado en "Acerca de" |
| center_lat | DOUBLE NOT NULL | centro de mapa por defecto |
| center_lng | DOUBLE NOT NULL | centro de mapa por defecto |
| default_locale | VARCHAR(5) NOT NULL | `es` / `ca` |

## app_config (tabla de configuración; parámetros del bootstrap, req. #5-7)
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| city_id | CHAR(36) FK cities | configuración por ciudad |
| reservation_window_min | INT NOT NULL | ventana de llegada (p. ej. 30) |
| max_use_min | INT NOT NULL | uso máximo de plaza (p. ej. 840) |
| reservation_warnings_min | JSON | offsets de aviso de reserva: `[10,5]` |
| use_warnings_min | JSON | offsets de aviso de uso: `[30,15,5]` |
| overstay_interval_min | INT | aviso tras exceder: 30 |
| terms_url | VARCHAR(255) | URL legal de términos |
| privacy_url | VARCHAR(255) | URL legal de privacidad |

Los datos de versión de app **ya no viven aquí**: se gestionan en la tabla `app_versions` (abajo), consultada por `POST /check_version`.

## app_versions (comprobación de versión, req. #2)
Tabla real del hosting que respalda `POST /check_version`.
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | BIGINT AUTO_INCREMENT PK | |
| platform | ENUM('android','ios') NOT NULL | plataforma del binario |
| version_code | VARCHAR(20) NOT NULL | versión legible, p. ej. `1.0.0` |
| build_number | INT NOT NULL | número de build incremental |
| release_date | DATE | fecha de publicación |
| force_update | TINYINT(1) NOT NULL DEFAULT 0 | si la versión exige actualización obligatoria |
| min_supported_build | INT | build mínimo soportado; por debajo ⇒ `force_update` en la respuesta |
| url | VARCHAR(255) | enlace de la tienda para actualizar |
| created_at | DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) | |

`POST /check_version` devuelve la última fila por `platform` (`latest_version`/`latest_build` = `version_code`/`build_number` de la más reciente), `force_update` (por bandera de la versión o por `build_number` del cliente < `min_supported_build`), `url`, y `client_known` (si la combinación plataforma + build recibida existe/está contemplada).

## users
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | CHAR(36) PK | |
| email | VARCHAR(190) UNIQUE NOT NULL | 190 por el límite de índice utf8mb4 |
| password_hash | VARCHAR(255) NOT NULL | argon2id |
| name | VARCHAR(120) | |
| phone | VARCHAR(30) | opcional |
| city_id | CHAR(36) FK cities | ciudad de alta |
| notifications_enabled | TINYINT(1) NOT NULL DEFAULT 1 | preferencia del conmutador de ajustes (RF-6.2; sin efecto hasta activar push central) |
| locale | VARCHAR(5) NULL | `es`/`ca`/null (null = sistema) |
| created_at | DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) | |
| updated_at | DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) | |
| deleted_at | DATETIME(6) NULL | borrado lógico (fuera de UI v1) |

## vehicles (RF-5.4, S)
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | CHAR(36) PK | |
| user_id | CHAR(36) FK users | |
| type | ENUM('scooter','bike','ebike','other') NOT NULL | |
| nickname | VARCHAR(60) | |

## parkings
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | CHAR(36) PK | |
| city_id | CHAR(36) FK cities | los flavors solo ven su ciudad |
| name | VARCHAR(150) NOT NULL | |
| address | VARCHAR(255) NOT NULL | |
| lat | DOUBLE NOT NULL | |
| lng | DOUBLE NOT NULL | |
| total_spots | INT NOT NULL | |
| status | ENUM('operational','maintenance','offline') NOT NULL DEFAULT 'operational' | offline ⇒ no reservable |
| allowed_types | JSON | array de tipos de VMP admitidos, p. ej. `["scooter","bike","ebike"]` |
| opening_hours | JSON NULL | null = 24 h |
| photos | JSON | array de URLs |
| gateway_id | VARCHAR(100) | identificador en la pasarela hardware |
| door_ids | JSON | array de puertas controlables |

**Ocupación**: `available_spots = total_spots − count(reservations WHERE parking_id = X AND status IN ('pending','active'))`. Vista o cálculo en consulta, nunca contador manual.

## favorites
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| user_id | CHAR(36) FK users | |
| parking_id | CHAR(36) FK parkings | |

`PRIMARY KEY (user_id, parking_id)`. Sustituye a los favoritos locales.

## reservations
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | CHAR(36) PK | |
| user_id | CHAR(36) FK | ver índice único de más abajo |
| parking_id | CHAR(36) FK | |
| status | ENUM('pending','active','completed','cancelled','expired') NOT NULL | |
| created_at | DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) | |
| expires_at | DATETIME(6) NOT NULL | created_at + ventana llegada (30 min, configurable por parking) |
| checkin_at | DATETIME(6) NULL | primer open exitoso |
| max_until | DATETIME(6) NULL | checkin_at + uso máximo (14 h, configurable) |
| checkout_at | DATETIME(6) NULL | |
| price_cents | INT NOT NULL DEFAULT 0 | preparado para tarifas futuras; siempre 0 en v1 |
| currency | CHAR(3) NOT NULL DEFAULT 'EUR' | |
| active_lock | CHAR(36) NULL | columna normal mantenida por **triggers**; sostiene el índice único parcial |

**Regla RF-3.2 (una sola reserva/uso activo por usuario)**: como MySQL/MariaDB no tiene índices parciales, se emula con la columna `active_lock` (= `user_id` solo mientras la reserva está `pending`/`active`, `NULL` en el resto) y un índice **`UNIQUE (active_lock)`**. Así un segundo `pending`/`active` del mismo usuario viola el índice; los estados finales quedan a `NULL` y no colisionan (en SQL un `NULL` no es igual a otro `NULL`).

> **Corrección (verificada contra MariaDB 10.3 y 10.11, jul-2026).** La versión anterior de este spec definía `active_lock` como **columna generada** (`AS (IF(...)) VIRTUAL`). **No es implementable**: MariaDB rechaza con el error 1901 cualquier columna generada que use una función (`IF`, `CASE`, incluso `SUBSTRING`) **si lleva un índice**, porque solo admite expresiones de su lista de deterministas. Da igual `VIRTUAL` o `PERSISTENT`, y da igual declarar el índice en el `CREATE TABLE` o añadirlo después.
>
> En su lugar, `active_lock` es una **columna normal** mantenida por dos triggers, `BEFORE INSERT` y `BEFORE UPDATE`:
> ```sql
> SET NEW.active_lock = IF(NEW.status IN ('pending','active'), NEW.user_id, NULL);
> ```
> La garantía sigue estando **en la base de datos y no en la aplicación**, que es lo esencial: dos peticiones simultáneas del mismo usuario pasarían ambas cualquier comprobación hecha en PHP antes de insertar. Además los triggers son inviolables desde la app: aunque escribiera `active_lock` a mano, el trigger lo sobrescribe.

## access_events (auditoría de aperturas, RF-4.6)
| Campo | Tipo (MySQL/MariaDB) | Notas |
|---|---|---|
| id | BIGINT AUTO_INCREMENT PK | |
| reservation_id | CHAR(36) FK reservations | |
| parking_id | CHAR(36) FK parkings | |
| door_id | VARCHAR(100) | puerta accionada |
| result | ENUM('opened','failed','timeout') NOT NULL | resultado devuelto por la pasarela |
| created_at | DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) | |

### Máquina de estados (única, la impone el backend)
```
                    cancel (antes de check-in)
              ┌───────────────────────────────► cancelled
              │
   pending ───┼── expira ventana de llegada ──► expired
              │
              └── open OK (check-in) ──► active ── open OK + "he retirado mi vehículo" (checkout) ──► completed
```
- `pending → active`: primer `POST /reservations/{id}/open` exitoso (check-in); arranca la cuenta de `max_until`.
- `pending → cancelled`: `POST /reservations/{id}/cancel` antes del check-in.
- `pending → expired`: vencida la ventana de llegada (`expires_at`); lo aplica el job de expiración (cron del hosting).
- `active → completed`: `POST /reservations/{id}/checkout` con confirmación del usuario.
