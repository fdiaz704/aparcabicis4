# 05 — Plan de desarrollo por fases

Reglas de ejecución (para el agente de código en VSCode):
- Una fase no empieza hasta que la anterior cumple su **Definition of Done (DoD)**.
- DoD común: `flutter analyze` sin warnings, tests de la fase en verde, commit por tarea `feat|fix|refactor(fase-N): …`, checkbox marcado aquí.
- Cada fase es demostrable en el emulador al terminar.

---

## FASE 0 — Limpieza, flavors e i18n base (app)
Objetivo: base limpia, multi-ciudad y sin literales de texto.
1. [x] Eliminar código muerto de `main_screen.dart` (`_HistoryTab`, `_ProfileTab`, `_SettingsTab`); sacar `lib/prueba.md` a `docs/`.
2. [x] Renombrar dominio: `BikeStation`→`Parking`, pantallas/rutas/textos "estación"→"aparcamiento".
3. [x] **Flavors**: `CityConfig` + `lib/config/cities/` (flavor `demo` con los 8 parkings de Madrid como seed), productFlavors Android + schemes iOS, `--dart-define=CITY=`. Cero referencias a ciudad fuera de config. _(schemes iOS pendientes: requieren macOS/Xcode; ver docs/FLAVORS.md)_
4. [ ] **i18n**: activar `flutter gen-l10n`, extraer TODOS los textos a `app_es.arb` y crear `app_ca.arb` (valencià) con claves completas (traducción inicial es→ca revisable).
5. [ ] Copiar `specs/` al repo + `CLAUDE.md` en raíz; lints estrictos y corregir avisos.

**DoD:** app compila por flavor (`demo`), funciona igual que antes, sin literales de UI en el código, analyze limpio.

## FASE 1 — Capa de repositorios + seguridad local (app)
Objetivo: fuentes de datos tras interfaces; sesión segura con biometría; todo contra fakes.
1. [ ] Interfaces `AuthRepository`, `ParkingsRepository`, `ReservationsRepository`, `AccessRepository`, `ConfigRepository` (bootstrap/params) + implementaciones `Fake*` (parkings del seed, params: ventana 30', uso 840', avisos {10,5}/{30,15,5}/30').
2. [ ] Providers dependen solo de interfaces (inyección por constructor); `SessionProvider` consume el bootstrap fake (user + params + currentReservation).
3. [ ] Persistencia unificada en `StorageService`; tokens en `flutter_secure_storage`; **eliminar el guardado de contraseña** ("Recuérdame" = mantener sesión).
4. [ ] **Biometría** (local_auth): alta al activar "Recuérdame"; restauración de sesión con huella/Face ID y fallback a contraseña (HU-2).
5. [ ] Botón "Abrir puerta" contra `FakeAccessRepository`: flujo reservar → open (check-in) → open + confirmar (checkout).
6. [ ] Tests unitarios de providers contra fakes + widget test del flujo completo.

**DoD:** ningún provider toca SharedPreferences/datos hardcodeados; biometría operativa en dispositivo; tests verdes.

## FASE 2 — UX de producto: mapa, avisos y ajustes (app, contra fakes)
Objetivo: implementar los requisitos de UI/UX (req. #2, #5, #6, #7, #9-12) sin backend.
1. [ ] **Mapa**: markers personalizados coloreados por disponibilidad (verde ≥60 % libre, amarillo 20-59,99 % libre, rojo <20 % libre), pinch/doble toque zoom, botón "mi ubicación" con geolocalización real y permisos.
2. [ ] Panel de **aparcamientos cercanos** ordenados por distancia; al elegir: **ruta** (Directions API, polyline + ETA) y advertencia si ETA > ventana de reserva restante (HU-4).
3. [ ] **LocalNotificationsService**: avisos de reserva (T−10', T−5', vencimiento) y de uso (T−30', T−15', T−5', luego cada 30' en exceso), programados contra `expiresAt`/`maxUntil`, cancelados en checkout/cancelación (HU-5, HU-6). Al vencer reserva: sync + volver al mapa.
4. [ ] **VersionCheckService** en splash: instalada vs tienda (`upgrader`) + respaldo `/config/app` (fake en esta fase); pantalla bloqueante de actualización (HU-1) y paso libre si la comprobación falla.
5. [ ] **Ajustes**: quitar tarjeta Cuenta; selector de idioma Sistema/Castellano/Valencià (persistido, cambio en caliente); conmutador de notificaciones que solo persiste preferencia con nota "próximamente"; modo oscuro funcional incl. iOS; tarjeta "Acerca de" (versión, ciudad, sistema, términos, privacidad desde CityConfig).
6. [ ] Tests de widget de mapa (colores de marker) y de programación/cancelación de notificaciones.

**DoD:** demo completa en emulador con fakes: mapa con colores y ruta, avisos locales disparándose (tiempos acortados en modo debug), ajustes bilingües sin controles sin efecto (salvo notificaciones, documentado).

## FASE 3 — Backend mínimo (repo nuevo `aparcabicis4-api`)
Objetivo: API REST desplegable en local (Docker) que cumple 04-API.md.
1. [ ] Scaffold Node.js (Fastify o NestJS) + PostgreSQL + Prisma; docker-compose (api + db + Mailpit).
2. [ ] Migraciones según 03 (incluye `cities` y `app_config`); seed: ciudad `demo` + 8 parkings + parámetros.
3. [ ] Auth completo (registro, login, refresh con rotación, forgot/reset).
4. [ ] `GET /config/app` y `GET /bootstrap` (user + params + stats + currentReservation).
5. [ ] Parkings (filtrados por ciudad) + favoritos + reservas con máquina de estados y job de expiración (cron 1').
6. [ ] Access con `SimGateController` (delay/tasa de fallo por env) + `access_events`; `PATCH /me/preferences`.
7. [ ] Historial `GET /reservations` con `from` por defecto = 3 meses; tests de integración + colección .http.

**DoD:** `docker compose up` levanta todo; flujo completo recorrible con la colección REST; tests verdes.

## FASE 4 — Conexión app ↔ API real
Objetivo: sustituir fakes por `Api*Repository`; eliminar todos los mocks.
1. [ ] `ApiClient` (Dio): base URL de CityConfig, interceptor JWT con refresh automático, mapeo de errores.
2. [ ] `ApiAuthRepository` + `ApiConfigRepository`: login/registro/forgot reales, bootstrap real al iniciar sesión (RF-B); si `currentReservation` existe, navegación directa al uso activo y bloqueo de nuevas reservas.
3. [ ] `ApiParkingsRepository`: polling 30 s, favoritos remotos, distancia con posición real.
4. [ ] `ApiReservationsRepository` + `ApiAccessRepository`: reserva/cancel/open/checkout reales; reprogramación de notificaciones locales con cada sync de `expiresAt`/`maxUntil`; historial remoto 3 meses con caché.
5. [ ] `/config/app` real en el VersionCheckService; preferencia de notificaciones/idioma sincronizada (`PATCH /me/preferences`).
6. [ ] Entornos: `dev`=fakes, `staging/prod`=API. Eliminar todo `// TODO` de auth mock.

**DoD:** con la API local, un usuario nuevo completa registro → bootstrap → reserva con ruta → open (sim) → avisos → checkout → historial, sin ningún dato mock; arra