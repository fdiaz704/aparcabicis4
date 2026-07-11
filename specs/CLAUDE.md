# CLAUDE.md — Instrucciones para el agente de código (VSCode / Claude Code)

> Copiar este archivo a la RAÍZ del repositorio de la app Flutter. En el repo del backend (`aparcabicis4-api`), copiar la sección "Backend".

## Contexto
Proyecto **Aparcabicis4**: app Flutter para aparcamientos cerrados inteligentes de VMP, evolución del código existente de este mismo repositorio. Las especificaciones completas están en `specs/`:

1. `specs/00-VISION.md` — qué es el producto y decisiones fijadas
2. `specs/01-REQUISITOS.md` — requisitos RF/RNF e historias con criterios de aceptación
3. `specs/02-ARQUITECTURA.md` — capas, qué se conserva del código actual y qué cambia
4. `specs/03-MODELO-DATOS.md` — entidades y máquina de estados de reservas
5. `specs/04-API.md` — contrato REST (fuente de verdad entre app y backend)
6. `specs/05-PLAN-FASES.md` — plan de trabajo; **ejecutar SIEMPRE en orden de fases**

## Reglas de trabajo
- **Fase actual primero.** Lee `specs/05-PLAN-FASES.md`, identifica la primera fase con tareas pendientes y trabaja SOLO en ella. No adelantes trabajo de fases posteriores.
- **El contrato API manda.** Cualquier duda entre app y backend se resuelve mirando `specs/04-API.md`. Si el contrato debe cambiar, edita primero el spec y explica el porqué en el commit.
- **Arquitectura obligatoria:** UI → Provider → Repositorio (interfaz) → ApiClient/Fake. Prohibido: HTTP desde pantallas o providers, SharedPreferences fuera de `StorageService`, secretos hardcodeados.
- **El backend es la fuente de verdad** de estados y tiempos de reserva. Los timers de la app son solo visuales, sincronizados con `expiresAt`/`maxUntil`.
- **Seguridad:** tokens solo en `flutter_secure_storage`. NUNCA persistir contraseñas. Nada de claves/API keys en el repo (usar `--dart-define` o .env ignorado por git).
- **Multi-ciudad:** ninguna clase fuera de `lib/config/` puede conocer la ciudad; todo llega por `CityConfig` inyectado. Nada de coordenadas, nombres de ciudad o URLs hardcodeadas.
- **i18n:** TODOS los textos de UI en ARB (`app_es.arb` + `app_ca.arb`). Prohibido añadir literales de texto en widgets.
- **Notificaciones de tiempo (reserva/uso):** siempre locales (`flutter_local_notifications`), programadas contra `expiresAt`/`maxUntil` del servidor. El push central NO existe en v1.
- **Idioma:** código e identificadores en inglés; textos de UI, comentarios de dominio y mensajes de commit descriptivos en español.

## Definition of Done (cada tarea)
1. `flutter analyze` sin warnings.
2. Tests de la fase en verde (`flutter test`).
3. La app compila y el flujo afectado es demostrable en emulador.
4. Commit atómico: `feat|fix|refactor(fase-N): descripción`.
5. Marcar la tarea como hecha (checkbox) en `specs/05-PLAN-FASES.md`.

## Comandos
```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=ENV=dev        # dev = repositorios fake, sin backend
flutter run --dart-define=ENV=staging    # staging = API local (docker compose up en aparcabicis4-api)
```

## Backend (repo aparcabicis4-api — fase 3)
- Stack: Node.js (Fastify o NestJS) + PostgreSQL + Prisma, JWT RS256, Docker.
- Implementar exactamente `specs/04-API.md` y `specs/03-MODELO-DATOS.md`.
- La pasarela hardware se desarrolla contra `SimGateCo