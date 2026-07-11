# Paquete de especificaciones Aparcabicis4 — cómo usarlo en VSCodium/VSCode (Linux)

## Contenido
| Archivo | Qué contiene |
|---|---|
| 00-VISION.md | Producto, alcance v1, decisiones fijadas |
| 01-REQUISITOS.md | RF/RNF priorizados + historias con criterios de aceptación |
| 02-ARQUITECTURA.md | Capas, qué se reutiliza de Aparcabicis4, secuencia de apertura |
| 03-MODELO-DATOS.md | Esquema BD + máquina de estados de reservas |
| 04-API.md | Contrato REST app↔backend (fuente de verdad) |
| 05-PLAN-FASES.md | 6 fases ejecutables con DoD por fase |
| CLAUDE.md | Instrucciones para el agente de código (raíz del repo) |

## Puesta en marcha
```bash
# 1. En el repo de la app Flutter (Aparcabicis4)
mkdir -p specs && cp <esta_carpeta>/*.md specs/
mv specs/CLAUDE.md ./CLAUDE.md          # CLAUDE.md va en la raíz

# 2. Instalar Claude Code en Linux (si no lo tienes)
npm install -g @anthropic-ai/claude-code
# En VSCode: extensión "Claude Code" o terminal integrado

# 3. Arrancar la fase 0
cd <repo> && claude
> Lee CLAUDE.md y specs/05-PLAN-FASES.md. Ejecuta la FASE 0 completa,
> tarea por tarea, con un commit por tarea, y marca los checkboxes al terminar.
```

## Ritmo de trabajo recomendado
- Una sesión por fase (o por bloque de tareas). Empieza cada sesión con: "¿en qué fase estamos según specs/05-PLAN-FASES.md? Continúa desde ahí".
- Revisa el diff de cada commit antes de pasar a la siguiente tarea.
- Si una decisión de spec resulta errónea durante la implementación: se corrige primero el archivo de specs y luego el código, nunca al revés.
- El backend (fase 3) vive en un repositorio separado `aparcabicis4-api` con su propia copia de CLAUDE.md (sección Backend) + 03 y 04.

## Trabajo mixto: ediciones manuales + agente (VSCodium)
La extensión de Claude en VSCodium es un envoltorio del CLI `claude`; todo lo anterior aplica igual. Reglas para no pisarse:
- **Un autor por commit**: commitea tus ediciones manuales ANTES de lanzar una tarea al agente, y deja que el agente haga sus propios commits. Nunca mezclar ambos en un mismo commit.
- Si editas a mano durante una tarea del agente en curso, avísale en el prompt siguiente: "he modificado <archivo> a mano, léelo antes de continuar".
- Tras ediciones manuales relevantes, pide al agente: "revisa mi último commit contra las specs y señala incoherencias".
- Si la extensión fallara en VSCodium, el terminal integrado con `claude` da exactamente el mismo resultado.
