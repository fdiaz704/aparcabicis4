# Documentación de Aparcabicis4

## Índice
1. [Descripción General](#descripción-general)
2. [Características Principales](#características-principales)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Flujo de la Aplicación](#flujo-de-la-aplicación)
5. [Autenticación y Usuarios](#autenticación-y-usuarios)
6. [Gestión de Estaciones](#gestión-de-estaciones)
7. [Reservas](#reservas)
8. [Historial](#historial)
9. [Perfil y Configuración](#perfil-y-configuración)
10. [Tecnologías Utilizadas](#tecnologías-utilizadas)

## Descripción General

Aparcabicis4 es una aplicación móvil diseñada para facilitar el alquiler de bicicletas en estaciones de aparcamiento. La aplicación permite a los usuarios localizar estaciones cercanas, ver la disponibilidad de bicicletas, realizar reservas y gestionar su historial de uso.

## Características Principales

- **Autenticación de usuarios** con registro, inicio de sesión y recuperación de contraseña
- **Mapa interactivo** para visualizar estaciones de bicicletas cercanas
- **Lista de estaciones** con información detallada de disponibilidad
- **Sistema de reservas** en tiempo real
- **Historial de viajes** con detalles de cada reserva
- **Perfil de usuario** con opciones de personalización
- **Tema adaptable** que se ajusta al sistema operativo del dispositivo
- **Diseño responsivo** para diferentes tamaños de pantalla

## Estructura del Proyecto

```
lib/
├── main.dart                # Punto de entrada de la aplicación
├── models/                  # Modelos de datos
│   ├── bike_station.dart    # Modelo de estación de bicicletas
│   ├── reservation_record.dart # Modelo de registro de reservas
│   └── user.dart            # Modelo de usuario
├── providers/               # Proveedores de estado
│   ├── auth_provider.dart   # Manejo de autenticación
│   ├── reservations_provider.dart # Gestión de reservas
│   └── stations_provider.dart     # Gestión de estaciones
├── screens/                 # Pantallas de la aplicación
│   ├── login/               # Pantallas de autenticación
│   │   ├── login_screen.dart
│   │   ├── create_user_screen.dart
│   │   ├── change_password_screen.dart
│   │   └── delete_user_screen.dart
│   └── main/                # Pantallas principales
│       ├── main_screen.dart
│       ├── bike_stations_list.dart
│       ├── bike_stations_map.dart
│       ├── active_reservation_screen.dart
│       ├── history_screen.dart
│       ├── profile_screen.dart
│       └── settings_screen.dart
├── services/                # Servicios
│   ├── navigation_service.dart
│   └── storage_service.dart
├── utils/                   # Utilidades
│   ├── constants.dart
│   ├── adaptive_theme.dart
│   └── platform_*.dart      # Utilidades específicas de plataforma
└── widgets/                 # Componentes reutilizables
    ├── bike_station_card.dart
    ├── history_card.dart
    └── stat_card.dart
```

## Flujo de la Aplicación

1. **Pantalla de Inicio (Splash Screen)**
   - Muestra el logo de la aplicación
   - Verifica si hay una sesión activa
   - Redirige al usuario a la pantalla de inicio de sesión o a la pantalla principal

2. **Autenticación**
   - Inicio de sesión con correo electrónico y contraseña
   - Opción de "Recordar credenciales"
   - Registro de nuevos usuarios
   - Recuperación de contraseña

3. **Pantalla Principal**
   - Pestaña de Mapa: Muestra las estaciones en un mapa interactivo
   - Pestaña de Lista: Muestra las estaciones en una lista ordenada
   - Barra de búsqueda para filtrar estaciones

4. **Reserva de Bicicletas**
   - Selección de estación de origen
   - Visualización de disponibilidad en tiempo real
   - Confirmación de reserva
   - Código QR para desbloquear la bicicleta

5. **Historial de Viajes**
   - Lista de viajes realizados
   - Detalles de cada viaje (fecha, duración, estaciones, etc.)
   - Opción de calificación y comentarios

6. **Perfil y Configuración**
   - Información del usuario
   - Preferencias de la aplicación
   - Configuración de notificaciones
   - Cerrar sesión

## Autenticación y Usuarios

### Registro de Usuario
- Creación de nueva cuenta con correo electrónico y contraseña
- Validación de formato de correo electrónico
- Requisitos de seguridad para la contraseña

### Inicio de Sesión
- Autenticación con correo electrónico y contraseña
- Opción de "Recordar credenciales"
- Recuperación de contraseña mediante correo electrónico

### Gestión de Cuenta
- Cambio de contraseña
- Eliminación de cuenta
- Cierre de sesión

## Gestión de Estaciones

### Mapa Interactivo
- Visualización de estaciones en un mapa
- Marcadores con información de disponibilidad
- Filtrado por distancia y disponibilidad

### Lista de Estaciones
- Vista detallada de cada estación
- Información en tiempo real de bicicletas disponibles
- Ordenamiento por distancia o disponibilidad

## Reservas

### Realizar Reserva
- Selección de estación de origen
- Confirmación de disponibilidad
- Generación de código QR

### Reserva Activa
- Tiempo restante de la reserva
- Instrucciones de desbloqueo
- Opción de cancelación

## Historial

### Viajes Anteriores
- Lista cronológica de viajes realizados
- Detalles de cada viaje
- Estadísticas de uso

## Perfil y Configuración

### Información Personal
- Visualización de datos del usuario
- Actualización de información de contacto

### Preferencias
- Tema claro/oscuro
- Configuración de notificaciones
- Unidades de medida (km/millas)

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado
- **Shared Preferences**: Almacenamiento local de preferencias
- **Google Maps**: Integración de mapas
- **QR Code**: Generación de códigos QR
- **Firebase**: Autenticación y base de datos en tiempo real (si está implementado)

## Requisitos del Sistema

- Android 6.0 o superior
- iOS 13.0 o posterior
- Conexión a Internet para la mayoría de las funcionalidades
- Permisos de ubicación para mostrar estaciones cercanas

## Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get` para instalar dependencias
3. Configurar las claves de API necesarias (Google Maps, etc.)
4. Ejecutar la aplicación en un dispositivo o emulador

## Soporte

Para reportar problemas o solicitar nuevas características, por favor abra un issue en el repositorio del proyecto.
