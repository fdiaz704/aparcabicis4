# ADR 0002 — Despliegue por ciudad (multi-tenant por base de datos)

- **Estado:** Aceptado
- **Fecha:** 2026-06-02
- **Decisión:** Cada ciudad (Palma, Alcorcón, …) tiene su **propia base de datos**, su **propio
  despliegue de backend** y su **propia build de la app** apuntando a su endpoint. El aislamiento de
  datos es por base de datos (un tenant = una BD = un despliegue), no por columna ni por esquema
  compartido.

## Contexto

La base de datos es **una por ciudad** (hoy solo existe `palma`). Los datos están **aislados por
diseño**: no hay un único almacén compartido entre ciudades ni una clave de tenant que multiplexe
filas de varias ciudades en las mismas tablas.

Sobre este punto de partida caben dos modelos:

1. **Multi-tenant en runtime** (una BD/instancia que enruta por tenant según la petición), o
2. **Despliegue por ciudad** (cada ciudad es un despliegue independiente que conecta a su propia BD).

Dado que el aislamiento por BD ya es el hecho de partida y que las ciudades son clientes/contratos
separados (R3 RECYMED y operadores municipales distintos), se elige el modelo de **despliegue por
ciudad**.

## Decisión

**Un despliegue independiente por ciudad.** Cada despliegue:

- Conecta a **su** base de datos (Palma → BD `palma`, Alcorcón → su BD, …).
- Corre **su propia instancia** de backend.
- Es consumido por **su propia build** de la app Flutter, compilada apuntando al endpoint de esa
  ciudad.

### Requisito de diseño (innegociable)

- **UNA sola base de código backend y UNA sola app Flutter.** Ambas se **parametrizan por
  configuración/build por ciudad**.
- **Prohibido bifurcar el código por ciudad.** No hay ramas, carpetas ni forks `palma/`, `alcorcon/`.
  Una diferencia entre ciudades es siempre un valor de configuración, nunca una rama de código.
- **Toda config que varía por ciudad vive en la configuración del despliegue, no en el código:**
  endpoint de la API, credenciales/cadena de conexión de la BD, SMTP, clave de Google Maps, reglas
  de registro, y cualquier otro parámetro específico de ciudad.

## Consecuencias

- **El backend NO enruta BD en runtime.** No hay resolución de tenant por petición: cada despliegue
  está cableado a su BD por configuración al arrancar. Esto simplifica el backend (sin middleware de
  tenant, sin riesgo de fuga de datos entre ciudades por enrutado incorrecto).
- **Usuarios separados por ciudad.** Las cuentas son **independientes por ciudad**; **no hay
  identidad única entre ciudades**. Un usuario de Palma que quiera usar Alcorcón se registra de nuevo
  allí. (Si en el futuro se quisiera identidad federada, sería un nuevo ADR.)
- **Se asume gestionar N despliegues.** Operar la solución implica desplegar, monitorizar, actualizar
  y respaldar N backends y N bases de datos. El coste operativo crece linealmente con el número de
  ciudades; se acepta a cambio del aislamiento fuerte y la simplicidad del backend.
- **La app se distribuye por ciudad.** Cada ciudad tiene su build (su endpoint, su clave de Maps, su
  branding/reglas si difieren), pero **desde el mismo código fuente**, mediante *flavors* / `--dart-define`
  / ficheros de configuración por entorno.
- **Disciplina de configuración.** El catálogo de parámetros por ciudad debe estar documentado y
  versionado (sin secretos en el repo; ver deuda de seguridad de claves en `CLAUDE.md` y
  [ADR 0001](0001-backend.md)). Añadir una ciudad = crear su BD + su despliegue + su build, **sin
  tocar código**.

## Alcance v1

- **Solo Palma.** Alcorcón y el resto de ciudades quedan fuera del alcance v1, pero la arquitectura
  (config por despliegue, cero bifurcación) se diseña desde ya para soportarlas sin reescritura.
