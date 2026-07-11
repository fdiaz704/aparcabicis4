# 00 — Visión del producto

## Nombre de trabajo
**Aparcabicis4** (se mantiene el nombre del proyecto actual; el naming comercial por ciudad se define en el flavor, ver RF-0)

## Qué es
Aplicación móvil (Android/iOS, Flutter) para localizar, reservar y usar **aparcamientos cerrados inteligentes para VMP** (patinetes eléctricos, bicicletas, e-bikes). El usuario reserva una plaza, llega al aparcamiento y la app abre la puerta mediante **comando remoto vía backend**; al recoger el vehículo, la app registra el fin de uso.

## Qué NO es (v1)
- No incluye pagos ni tarifas (el modelo de datos queda preparado; ver 03).
- No incluye alquiler de vehículos: los VMP son del usuario.
- No incluye panel web de administración (se especifica en backlog, no en fases 1-5).

## Punto de partida
Código existente de **Aparcabicis4** (Flutter + Provider + SharedPreferences), con UI y flujo de reservas funcionales pero autenticación mock y datos estáticos. Se **evoluciona** ese código: se renombra el dominio (estación → aparcamiento/parking), se sustituyen mocks por un **backend propio (API REST)** y se añade el control de acceso remoto.

## Usuarios y escenario principal
Usuario de VMP en ciudad que necesita dejar su vehículo seguro (robo/vandalismo/intemperie).

Flujo feliz:
1. Abre la app → mapa/lista de aparcamientos con plazas libres en tiempo real.
2. Reserva una plaza (ventana de 30 min para llegar).
3. Llega, pulsa "Abrir puerta" → el backend valida la reserva y ordena la apertura al hardware del parking.
4. Aparca el VMP dentro; la reserva pasa a "en uso".
5. Al volver, pulsa "Abrir puerta" de nuevo, retira el vehículo y finaliza el uso.
6. El uso queda en el historial con duración y estadísticas.

## Restricciones técnicas acordadas
| Decisión | Valor |
|---|---|
| Base de código | Evolucionar Aparcabicis4 (Flutter) |
| Backend | Propio, API REST (contrato en 04-API.md; **PHP 8 + MySQL/MariaDB** sobre hosting **LAMP** existente, framework Slim o equivalente) |
| Apertura de puerta | Comando remoto app → backend → pasarela hardware (MQTT o API del fabricante) |
| Pagos | Fuera de v1; modelo de datos preparado |
| **Multi-ciudad** | Desarrollo estándar con un **flavor por ciudad** (config, branding, tiendas y API base por flavor) |
| Idiomas | Bilingüe: Sistema / Castellano / Valencià, seleccionable en ajustes |
| Actualización | Comprobación de versión de tiendas al arrancar; si hay versión nueva, actualización obligatori