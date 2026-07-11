# 03 — Modelo de datos

Esquema PostgreSQL (backend). Los modelos Dart de la app son proyecciones de estas entidades (solo los campos que la UI necesita).

## cities (multi-ciudad, req. #1)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| slug | text UNIQUE | coincide con el flavor (`valencia`, `demo`…) |
| name | text | mostrado en "Acerca de" |
| center_lat / center_lng | double | centro de mapa por defecto |
| default_locale | text | `es` / `ca` |

## app_config (tabla de configuración; parámetros del bootstrap, req. #5-7)
| Campo | Tipo | Notas |
|---|---|---|
| city_id | uuid FK cities | configuración por ciudad |
| reservation_window_min | int | ventana de llegada (p. ej. 30) |
| max_use_min | int | uso máximo de plaza (p. ej. 840) |
| reservation_warnings_min | int[] | offsets de aviso de reserva: `{10,5}` |
| use_warnings_min | int[] | offsets de aviso de uso: `{30,15,5}` |
| overstay_interval_min | int | aviso tras exceder: 30 |
| min_app_version / latest_app_version | text | respaldo de actualización forzada |
| force_update | bool | |
| store_url_android / store_url_ios | text | |
| terms_url / privacy_url | text | |

## users
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| email | text UNIQUE NOT NULL | |
| password_hash | text NOT NULL | argon2id |
| name | text | |
| phone | text | opcional |
| city_id | uuid FK cities | ciudad de alta |
| notifications_enabled | bool DEFAULT true | preferencia del conmutador de ajustes (RF-6.2; sin efecto hasta activar push central) |
| locale | text NULL | `es`/`ca`/null (null = sistema) |
| created_at / updated_at | timestamptz | |
| deleted_at | timestamptz NULL | borrado lógico (fuera de UI v1) |

## vehicles (RF-5.4, S)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK users | |
| type | enum: `scooter` `bike` `ebike` `other` | |
| nickname | text | |

## parkings
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| city_id | uuid FK cities | los flavors solo ven su ciudad |
| name | text NOT NULL | |
| address | text NOT NULL | |
| lat / lng | double NOT NULL | |
| total_spots | int NOT NULL | |
| status | enum: `operational` `maintenance` `offline` | offline ⇒ no reservable |
| allowed_types | enum[] | tipos de VMP admitidos |
| opening_hours | jsonb | null = 24 h |
| photos | text[] | URLs |
| gateway_id | text | identificador en la pasarela hardware |
| door_ids | text[] | puertas controlables |

**Ocupación**: `available_spots = total_spots − count(reservations WHERE parking_id = X AND status IN ('pending','active'))`. Vista o campo calculado, nunca contador manual.

## favorites
`user_id + parking_id` (PK compuesta). Sustituye a los favoritos locales.

## reservations
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK | índice parcial UNIQUE sobre (user_id) WHERE status IN ('pending','active') ⇒ garantiza RF-3.2 |
| parking_id | uuid FK | |
| status | enum: `pending` `active` `completed` `cancelled` `expired` | |
| created_at | timestamptz | |
| expires_at | timestamptz | created_at + ventana llegada (30 min, configurable por parking) |
| checkin_at | timestamptz NULL | primer open exitoso |
| max_until | timestamptz NULL | checkin_at + uso máximo (14 h, configurable) |
| checkout_at | timestamptz NULL | |
| price_cents | int DEFAULT 0 | preparado para tarifas futuras; siempre 0 en v1 |
| currency | char(3) DEFAULT 'EUR' | |

### Máquina de estados (única, la impone el backend)
```
pending ──open OK──► active ──open OK + confirma