# 04 — Contrato API REST (v1)

Base: `https://api.aparcabicis4.example/v1` · JSON · Auth: `Authorization: Bearer <access_token>` salvo donde se indique.
Errores: `{ "error": { "code": "RESERVATION_CONFLICT", "message": "..." } }` con HTTP semántico (400/401/403/404/409/422/503).

## Auth (público)
| Método | Ruta | Body | Respuesta |
|---|---|---|---|
| POST | /auth/register | `{email, password, name?}` | 201 `{user, accessToken, refreshToken}` |
| POST | /auth/login | `{email, password}` | 200 `{user, accessToken, refreshToken}` |
| POST | /auth/refresh | `{refreshToken}` | 200 `{accessToken, refreshToken}` (rotación) |
| POST | /auth/forgot-password | `{email}` | 202 (siempre, sin revelar existencia) |
| POST | /auth/reset-password | `{token, newPassword}` | 200 |

## Config de app (público — actualización forzada, req. #2)
| Método | Ruta | Respuesta |
|---|---|---|
| GET | /config/app?city=<slug>&platform=android\|ios | `{latestVersion, minVersion, forceUpdate, storeUrl, termsUrl, privacyUrl}` |

## Bootstrap de sesión (autenticado — req. #4)
| Método | Ruta | Respuesta |
|---|---|---|
| GET | /bootstrap | Una sola llamada tras login/restauración: |

```json
{
  "user": { "id":"…","email":"…","name":"…","phone":"…","notificationsEnabled":true,"locale":null },
  "params": {
    "reservationWindowMin": 30, "maxUseMin": 840,
    "reservationWarningsMin": [10,5], "useWarningsMin": [30,15,5],
    "overstayIntervalMin": 30
  },
  "stats": { "totalUses": 12, "totalMinutes": 940, "favoriteParkingId": "…" },
  "currentReservation": { "id":"…", "status":"active", "expiresAt":"…", "maxUntil":"…" }
}
```
`currentReservation: null` si no hay uso en curso. Si existe, la app navega al uso activo y bloquea nuevas reservas (además el backend responde 409).

## Usuario (autenticado)
| Método | Ruta | Notas |
|---|---|---|
| GET | /me | Perfil |
| PATCH | /me/preferences | `{notificationsEnabled?, locale?}` — conmutadores de ajustes (RF-6.2/6.3) |
| POST | /me/change-password | (C — fuera del UI v1, req. #11) |
| DELETE | /me | (C — fuera del UI v1, req. #11) |

## Parkings (autenticado)
| Método | Ruta | Notas |
|---|---|---|
| GET | /parkings?city=<slug>&lat=&lng=&q=&onlyAvailable= | Lista de la ciudad del flavor con `availableSpots` y `distanceMeters` si hay lat/lng; ordenable por distancia (lista de "más cercanos"). Polling cada 30 s |
| GET | /parkings/{id} | Ficha completa |
| PUT/DELETE | /parkings/{id}/favorite | Marcar/desmarcar favorito |
| GET | /me/favorites | Lista de favoritos |

Respuesta de parking:
```json
{
  "id": "…", "name": "Atocha Norte", "address": "…",
  "lat": 40.406, "lng": -3.689,
  "totalSpots": 20, "availableSpots": 7,
  "status": "operational", "allowedTypes": ["scooter","bike","ebike"],
  "openingHours": null, "photos": [], "isFavorite": true
}
```

## Reservas (autenticado)
| Método | Ruta | Notas |
|---|---|---|
| POST | /reservations | `{parkingId}` → 201 reserva `pending`. 409 `RESERVATION_CONFLICT` si ya hay activa; 409 `PARKING_FULL` si sin plazas; 422 si parking no operativo |
| GET | /reservations/current | 200 reserva `pending`/`active` o 404 |
| GET | /reservations?from=&to=&status=&page= | Historial paginado en JSON; por defecto `from = now − 3 meses` (req. #8) |
| POST | /reservations/{id}/cancel | Solo `pending` → `cancelled`; si no, 409 |
| POST | /reservations/{id}/checkout | Solo `active` + confirmación usuario → `completed` |

Respuesta de reserva:
```json
{
  "id": "…", "parkingId": "…", "parkingName": "Atocha Norte",
  "status": "pending",
  "createdAt": "2026-07-11T10:00:00Z",
  "expiresAt": "2026-07-11T10:30:00Z",
  "checkinAt": null, "maxUntil": null, "checkoutAt": null,
  "priceCents": 0, "currency": "EUR"
}
```
**La app calcula cuentas atrás contra `expiresAt`/`maxUntil` del