# Documentación del Módulo de Mapa

## Visión General
El módulo de mapa utiliza **Google Maps** para visualizar las estaciones de bicicletas en un mapa interactivo real. Permite a los usuarios ver la ubicación de las estaciones, su disponibilidad y realizar reservas.

## Archivos Principales

### 1. `lib/screens/main/bike_stations_map.dart`
Este es el componente principal de la interfaz de usuario.

*   **Implementación**: Utiliza el widget `GoogleMap` del paquete `google_maps_flutter`.
*   **Configuración del Mapa**:
    *   **Posición Inicial**: Centrado en Madrid (Puerta del Sol) con zoom 13.
    *   **Controles y Gestos**:
        *   `zoomControlsEnabled: false`: Controles nativos desactivados.
        *   **Botones Personalizados**: Se han añadido botones flotantes (+) y (-) para controlar el zoom manualmente.
        *   `zoomGesturesEnabled: true`: Pinch-to-zoom activado.
        *   `gestureRecognizers`: Se utiliza `ScaleGestureRecognizer` para asegurar que el mapa capture los gestos de zoom dentro de las pestañas.
        *   `scrollGesturesEnabled: false`: Desplazamiento desactivado para permitir la navegación "swipe" entre pestañas (Mapa <-> Lista).
        *   `myLocationEnabled: true`: Muestra la ubicación del usuario.
        *   `myLocationButtonEnabled: false`: Botón personalizado.
*   **Marcadores**:
    *   Se generan dinámicamente basándose en la lista de estaciones (`_createMarkers`).
    *   **Colores**:
        *   `Azul`: Reserva activa del usuario.
        *   `Verde`: Estación con plazas disponibles.
        *   `Rojo`: Estación sin plazas disponibles.
    *   **Interacción**: Al tocar un marcador, la cámara se anima hacia la estación y se muestra una tarjeta con detalles.
*   **Interfaz Superpuesta (Stack)**:
    *   Botón de geolocalización personalizado.
    *   Tarjeta de detalles de la estación seleccionada (nombre, dirección, disponibilidad, botón de reserva).

### 2. `lib/models/bike_station.dart`
Modelo de datos de la estación.

*   **Atributos Geográficos**: Utiliza `lat` y `lng` (double) para posicionar los marcadores en el mapa de Google.
*   **Otros Atributos**: `id`, `name`, `address`, `availableSpots`, `totalSpots`.

### 3. `lib/providers/stations_provider.dart`
Gestor de estado y datos.

*   **Datos**: Provee la lista de objetos `BikeStation` que se renderizan en el mapa.
*   **Gestión de Favoritos**: Permite marcar estaciones como favoritas.
*   **Lógica de Negocio**: Maneja la actualización de disponibilidad de plazas.

## Funcionalidades Clave
1.  **Visualización Real**: Uso de cartografía real para ubicar estaciones con precisión.
2.  **Zoom y Navegación**: Los usuarios pueden explorar el mapa libremente.
3.  **Estado en Tiempo Real**: Los marcadores reflejan visualmente la disponibilidad de plazas.
4.  **Gestión de Reservas**: Flujo integrado para reservar una bicicleta directamente desde el mapa.

## Próximos Pasos (Mejoras Potenciales)
*   Implementar la obtención real de la ubicación del usuario para el botón de "centrar".
*   Optimizar la carga de marcadores si el número de estaciones crece significativamente (clustering).
*   Añadir rutas de navegación hacia la estación seleccionada.
