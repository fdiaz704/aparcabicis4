# Documentación Técnica - Sistema Aparcabicis
## Aplicación móvil de reserva de plazas de aparcamiento para bicicletas

---

## 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Arquitectura de la Aplicación](#arquitectura-de-la-aplicación)
3. [Modelo de Datos](#modelo-de-datos)
4. [Pantallas y Componentes](#pantallas-y-componentes)
5. [Flujos de Navegación](#flujos-de-navegación)
6. [Lógica de Negocio](#lógica-de-negocio)
7. [Estados y Gestión de Datos](#estados-y-gestión-de-datos)
8. [Sistema de Diseño](#sistema-de-diseño)
9. [Persistencia de Datos](#persistencia-de-datos)
10. [Funcionalidades Especiales](#funcionalidades-especiales)

---

## 📱 Visión General

### Descripción
Sistema móvil de reserva y control de plazas de aparcamiento inteligente para bicicletas. Permite a los usuarios encontrar estaciones, reservar plazas, y controlar la apertura de puertas mediante smartphone.

### Características Principales
- ✅ Autenticación de usuarios con opción "Recuérdame"
- ✅ Vista de estaciones en lista y mapa
- ✓ Sistema de reservas con temporizador (30 minutos)
- ✅ Control de apertura de puertas inteligente
- ✅ Seguimiento de tiempo de uso (máximo 2 horas)
- ✅ Historial de reservas con estadísticas
- ✅ Sistema de favoritos
- ✅ Búsqueda y filtros avanzados
- ✅ Perfil de usuario
- ✅ Configuración y ayuda
- ✅ Geolocalización

### Tecnologías (Referencia React)
- **Framework**: React con TypeScript
- **Estilos**: Tailwind CSS
- **Componentes UI**: ShadCN (acordeón, badges, botones, cards, diálogos, inputs, etc.)
- **Iconos**: Lucide React
- **Notificaciones**: Sonner (Toasts)
- **Persistencia**: LocalStorage

---

## 🏗️ Arquitectura de la Aplicación

### Estructura de Navegación

```
App (Principal)
├── LoginScreen (No autenticado)
│   ├── CreateUserForm
│   ├── DeleteUserForm
│   ├── ChangePasswordForm
│   └── SendPasswordForm
│
└── Main App (Autenticado)
    ├── ActiveReservation (Si hay reserva activa)
    │
    └── Main Views (Sin reserva activa)
        ├── Main (Vista principal - default)
        │   ├── BikeStationsList (Pestaña Lista)
        │   └── BikeStationsMap (Pestaña Mapa)
        ├── History (Historial)
        ├── Profile (Perfil)
        └── Settings (Configuración)
            └── Help (Ayuda)
```

### Componentes Principales

1. **App.tsx** - Componente raíz y gestor de estado global
2. **LoginScreen** - Pantalla de inicio de sesión
3. **BikeStationsList** - Lista de estaciones con filtros
4. **BikeStationsMap** - Mapa con marcadores
5. **ActiveReservation** - Pantalla de reserva activa
6. **ReservationHistory** - Historial de uso
7. **UserProfile** - Perfil del usuario
8. **Settings** - Configuración
9. **Help** - Tutorial y ayuda

---

## 💾 Modelo de Datos

### BikeStation (Estación de aparcamiento)
```typescript
interface BikeStation {
  id: string;              // Identificador único
  name: string;            // Nombre de la estación (ej: "Plaza Mayor")
  address: string;         // Dirección completa
  availableSpots: number;  // Plazas disponibles actualmente
  totalSpots: number;      // Total de plazas en la estación
  lat: number;            // Latitud para el mapa
  lng: number;            // Longitud para el mapa
}
```

**Ejemplo de datos**:
```typescript
{
  id: '1',
  name: 'Plaza Mayor',
  address: 'Calle Mayor, 1',
  availableSpots: 3,
  totalSpots: 10,
  lat: 40.4155,
  lng: -3.7074
}
```

### ReservationRecord (Registro de reserva)
```typescript
interface ReservationRecord {
  id: string;              // Identificador único
  stationName: string;     // Nombre de la estación
  stationAddress: string;  // Dirección de la estación
  startTime: Date;         // Fecha/hora de inicio
  endTime: Date;          // Fecha/hora de fin
  duration: number;        // Duración en minutos
  status: 'completed' | 'cancelled';  // Estado de la reserva
}
```

### User (Usuario)
```typescript
interface User {
  email: string;  // Email del usuario
}
```

### Estados Globales (en App.tsx)
```typescript
{
  isLoggedIn: boolean;                    // Si el usuario está autenticado
  user: { email: string } | null;         // Datos del usuario
  activeReservation: BikeStation | null;  // Reserva activa actual
  reservationStartTime: Date | null;      // Momento de inicio de reserva
  stations: BikeStation[];                // Lista de estaciones
  reservationHistory: ReservationRecord[];// Historial de reservas
  favoriteStations: string[];             // IDs de estaciones favoritas
  currentView: 'main' | 'history' | 'profile' | 'settings' | 'help';
}
```

---

## 📱 Pantallas y Componentes

### 1. LoginScreen (Pantalla de Login)

**Ubicación**: Pantalla inicial (antes de autenticarse)

**Elementos UI**:
- Logo de bicicleta centrado
- Campo de email
- Campo de contraseña con botón de mostrar/ocultar (ojo)
- Checkbox "Recuérdame"
- Botón "Iniciar sesión"
- Botón hamburguesa (esquina superior izquierda)

**Funcionalidades**:
- Login con email y contraseña
- Toggle de visibilidad de contraseña (Eye/EyeOff icon)
- Opción "Recuérdame" guarda credenciales en localStorage
- Menú hamburguesa con overlay transparente

**Menú Hamburguesa** (Dialog con overlay transparente):
- Creación de usuario → navega a CreateUserForm
- Eliminación de usuario → navega a DeleteUserForm
- Cambio de contraseña → navega a ChangePasswordForm
- Recuperar contraseña → navega a SendPasswordForm

**Colores**:
- Fondo: Gradiente de azul claro (from-blue-50 to-blue-100)
- Botón primario: Color principal #7AB782

---

### 2. CreateUserForm (Creación de Usuario)

**Elementos UI**:
- Botón atrás (flecha izquierda)
- Campo: Nombre de usuario
- Campo: Email
- Campo: Contraseña (con toggle visibilidad)
- Campo: Confirmar contraseña (con toggle visibilidad)
- Botón "Cancelar" y "Crear usuario"

**Validaciones**:
- Email válido
- Contraseña mínimo 8 caracteres
- Contraseñas deben coincidir
- Todos los campos requeridos

**Flujo**:
1. Completar formulario
2. Validar datos
3. Mostrar toast de éxito
4. Volver a LoginScreen después de 1.5 segundos

---

### 3. ChangePasswordForm (Cambio de Contraseña)

**Elementos UI**:
- Botón atrás
- Campo: Email
- Campo: Contraseña actual (con toggle)
- Campo: Nueva contraseña (con toggle)
- Campo: Confirmar nueva contraseña (con toggle)
- Botones "Cancelar" y "Cambiar contraseña"

**Validaciones**:
- Email requerido
- Nueva contraseña mínimo 8 caracteres
- Contraseñas nuevas deben coincidir
- Nueva contraseña debe ser diferente a la actual

---

### 4. DeleteUserForm (Eliminar Cuenta)

**Elementos UI**:
- Botón atrás
- Advertencia: "Esta acción es permanente y no se puede deshacer"
- Campo: Email
- Campo: Contraseña (con toggle)
- Campo: Confirmar contraseña (con toggle)
- Campo: Escribir "ELIMINAR" para confirmar
- Botones "Cancelar" (outline) y "Eliminar cuenta" (destructive/rojo)

**Validaciones**:
- Contraseñas deben coincidir
- Debe escribir exactamente "ELIMINAR" (case insensitive)
- Botón de eliminar deshabilitado hasta confirmar

---

### 5. SendPasswordForm (Recuperar Contraseña)

**Elementos UI**:
- Botón atrás
- Campo: Email
- Descripción de instrucciones
- Botones "Cancelar" y "Enviar email"

**Estados**:
- **No enviado**: Muestra formulario
- **Enviado**: Muestra confirmación con:
    - Alert verde con check
    - Mensaje de confirmación
    - Instrucciones adicionales
    - Botones "Enviar de nuevo" y "Volver al login"

---

### 6. Main View (Vista Principal) - Después del Login

**Header**:
- Ícono de bicicleta + "Aparcabicis" (izquierda)
- Botón de cerrar sesión/LogOut (derecha)
- Color de fondo: #7AB782

**Pestañas** (Tabs):
- **Lista**: Muestra BikeStationsList
- **Mapa**: Muestra BikeStationsMap

**Navegación Inferior** (Bottom Navigation - 4 botones):
1. **Estaciones** (Bike icon) - Vista principal
2. **Historial** (History icon) - Historial de reservas
3. **Perfil** (User icon) - Perfil de usuario
4. **Ajustes** (Settings icon) - Configuración

---

### 7. BikeStationsList (Lista de Estaciones)

**Elementos UI**:
- **Barra de búsqueda**: Input con icono de lupa
- **Botón de filtros**: Icono de sliders con badge de contador de filtros activos
- **Lista scrolleable**: Cards de estaciones

**Filtros** (Panel lateral Sheet):
- **Solo disponibles**: Switch para mostrar solo con plazas
- **Solo favoritos**: Switch para mostrar favoritos
- **Ordenar por**:
    - Sin ordenar
    - Nombre (A-Z)
    - Disponibilidad (más a menos)
- **Limpiar filtros**: Botón para resetear

**BikeStationCard** (Tarjeta individual):
```
┌──────────────────────────────────────┐
│ [Nombre Estación]  ⭐  [Badge: 3/10] │
│ 📍 Dirección                         │
│                                      │
│ 🚲 3 plazas disponibles   [Reservar] │
└──────────────────────────────────────┘
```

**Elementos de la Card**:
- Título de estación
- Botón estrella (favorito - amarillo si es favorito)
- Badge de disponibilidad:
    - Verde (#7AB782) si hay plazas
    - Rojo si no hay plazas
- Dirección con icono de ubicación
- Texto de plazas disponibles
- Botón "Reservar":
    - Habilitado y color primario si hay plazas
    - Deshabilitado y rojo si no hay plazas

---

### 8. BikeStationsMap (Mapa de Estaciones)

**Elementos UI**:
- Mapa simulado con gradiente (from-blue-100 to-green-100)
- Grid de fondo (20px x 20px)
- Marcadores de estaciones (MapPin icons)
- Botón de geolocalización (esquina superior derecha)
- Card de información de estación seleccionada (parte inferior)

**Marcadores**:
- **Verde** (#7AB782): Estaciones con plazas disponibles
- **Rojo**: Sin plazas disponibles
- **Azul pulsante**: Estación con reserva activa (animación pulse)

**Posicionamiento**:
- Marcadores distribuidos en grid sobre el mapa
- Formula:
    - top = 20 + (index % 5) * 15
    - left = 20 + floor(index / 5) * 20

**Ubicación del Usuario**:
- Punto azul pulsante en el centro
- Se activa al presionar botón de navegación (Navigation icon)
- Usa geolocalización del navegador

**Card de Estación Seleccionada** (al tocar marcador):
```
┌────────────────────────────────────────┐
│ [Nombre]  ⭐                        [X] │
│ 📍 Dirección                           │
│                                        │
│ 3 plazas disponibles de 10  [⭐][Res.] │
└────────────────────────────────────────┘
```

**Elementos**:
- Nombre de estación con estrella si es favorita
- Botón X para cerrar
- Dirección
- Disponibilidad (verde o rojo)
- Botón estrella (toggle favorito)
- Botón "Reservar"

---

### 9. ActiveReservation (Reserva Activa)

**IMPORTANTE**: Esta pantalla es de pantalla completa y reemplaza toda la UI mientras hay una reserva activa.

**Header**:
- Mapa simulado con marcador de la estación (altura: 192px)
- Badge de estado:
    - "Reservada" (secondary) - Durante los primeros 30 minutos
    - "En uso" (default/verde) - Después de abrir la primera vez

**Estados de Reserva**:

#### Estado 1: "Reservada" (Primeros 30 minutos)
```
┌──────────────────────────────────────┐
│      [Mapa con marcador azul]        │
│  Badge: "Reservada"                  │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ [Nombre de Estación]                 │
│ 📍 Dirección                         │
│                                      │
│ Tiempo restante de reserva          │
│ 🕐 14m 32s                           │
│ [====Progress Bar================]   │
│                                      │
│ ⚠ Abre la puerta para comenzar...   │
│                                      │
│ [    🔓 Abrir puerta    ] (grande)   │
│                                      │
│ [  Cancelar reserva  ] (outline)     │
└──────────────────────────────────────┘
```

**Funcionalidad**:
- Temporizador de cuenta regresiva (30 minutos)
- Progress bar que disminuye
- Alert con instrucciones
- Botón grande "Abrir puerta"
- Botón "Cancelar reserva" (con confirmación)

**Timer**:
- Comienza en 15:00 (900 segundos)
- Actualiza cada segundo
- Cuando llega a 0, cancela automáticamente la reserva
- A los 10 minutos (5 min restantes), muestra notificación de advertencia

#### Estado 2: "En uso" (Después de primera apertura)
```
┌──────────────────────────────────────┐
│      [Mapa con marcador azul]        │
│  Badge: "En uso"                     │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ [Nombre de Estación]                 │
│ 📍 Dirección                         │
│                                      │
│ Tiempo de uso                        │
│ 🕐 1h 23m 45s                        │
│ [====Progress Bar========>      ]   │
│ Tiempo máximo: 2h 0m 0s             │
│                                      │
│ ℹ Puedes abrir y cerrar la puerta   │
│   tantas veces como necesites...    │
│                                      │
│ [    🔓 Abrir puerta    ] (grande)   │
│                                      │
│ [   Finalizar uso   ] (outline)      │
└──────────────────────────────────────┘
```

**Funcionalidad**:
- Temporizador de cuenta ascendente (desde 0)
- Progress bar que aumenta
- Máximo: 2 horas (7200 segundos)
- Botón "Abrir puerta" siempre disponible
- Botón "Finalizar uso"

**Transición de Estado**:
- Al presionar "Abrir puerta" por primera vez en estado "Reservada":
    1. Cambia estado a "En uso"
    2. Detiene timer de reserva
    3. Inicia timer de uso desde 0
    4. Muestra toast verde: "Puerta abierta correctamente"

**Apertura de Puerta**:
- Muestra Alert verde durante 3 segundos: "Puerta abierta correctamente"
- No tiene límite de veces que se puede presionar
- Funciona tanto en "Reservada" como "En uso"

**Modal de Finalización** (al presionar "Finalizar uso"):
```
┌──────────────────────────────────────┐
│     Instrucciones finales            │
│                                      │
│  ① Retire todas sus pertenencias    │
│                                      │
│  ② Cierre la puerta                 │
│                                      │
│  ③ La plaza quedará disponible      │
│     para otros usuarios              │
│                                      │
│  Toca en cualquier parte para       │
│  continuar                           │
└──────────────────────────────────────┘
```

**Características del Modal**:
- Overlay gris semi-transparente (clickeable)
- Contenido centrado
- Se puede cerrar tocando en cualquier parte (overlay o contenido)
- Al cerrar, regresa a la vista principal de estaciones
- Círculos numerados con color #7AB782

---

### 10. ReservationHistory (Historial de Reservas)

**Header**:
- Botón atrás (flecha)
- Título "Historial"
- Botón cerrar sesión
- Color: #7AB782

**Sección de Estadísticas** (Grid 3 columnas):
```
┌──────┬──────┬──────┐
│  15  │  12  │ 45m  │
│Total │Compl.│Prom. │
└──────┴──────┴──────┘
```

**Cards de Estadísticas**:
- **Total**: Número total de reservas
- **Completadas**: Reservas con status 'completed' (verde)
- **Promedio**: Duración promedio en minutos (azul)

**Lista de Reservas** (Scrolleable):

Cada tarjeta muestra:
```
┌──────────────────────────────────────┐
│ [Nombre Estación]      [Badge status]│
│ 📍 Dirección                         │
│ ──────────────────────────────────── │
│ 📅 07 oct 2025, 10:30               │
│ 🕐 Duración: 45m                     │
└──────────────────────────────────────┘
```

**Badges de Estado**:
- **Completada**: Badge verde/default
- **Cancelada**: Badge gris/secondary

**Ordenamiento**:
- Más recientes primero (por startTime descendente)

**Estado Vacío**:
- Icono de TrendingUp (gris)
- Texto: "Aún no tienes reservas"
- Subtexto: "Cuando realices una reserva, aparecerá aquí"

---

### 11. UserProfile (Perfil de Usuario)

**Estructura**:

**Card de Información Personal**:
```
┌──────────────────────────────────────┐
│    📧 usuario@email.com              │
│                                      │
│    [✏️ Editar perfil] (opcional)     │
└──────────────────────────────────────┘
```

**Card de Estadísticas de Uso**:
```
┌──────────────────────────────────────┐
│  Estadísticas de Uso                 │
│ ──────────────────────────────────── │
│  🚲  Total reservas        15        │
│ ──────────────────────────────────── │
│  🕐  Tiempo total          12h 30m   │
│ ──────────────────────────────────── │
│  ⭐  Estación favorita     Plaza Mayor│
└──────────────────────────────────────┘
```

**Estadísticas Calculadas**:
- **Total reservas**: Longitud del array de reservations
- **Tiempo total**: Suma de duration de todas las reservas completadas
- **Estación favorita**: La estación con más reservas (frecuencia)

**Card de Información de Cuenta**:
```
┌──────────────────────────────────────┐
│  Información de Cuenta               │
│ ──────────────────────────────────── │
│  📅 Miembro desde    Octubre 2025    │
│ ──────────────────────────────────── │
│  📧 Email verificado  ✓ Verificado   │
└──────────────────────────────────────┘
```

**Colores de íconos**:
- Bike: Fondo azul claro, ícono azul
- Clock: Fondo verde claro, ícono verde
- Star: Fondo amarillo claro, ícono amarillo

---

### 12. Settings (Configuración)

**Estructura Simplificada**:

**Card "Ayuda y soporte"**:
```
┌──────────────────────────────────────┐
│  ❓ Ayuda y soporte                  │
│ ──────────────────────────────────── │
│  [ℹ️ Tutorial de la app]            │
│  [📞 Llamar a soporte]              │
└──────────────────────────────────────┘
```

**Card "Información de la app"**:
```
┌──────────────────────────────────────┐
│  Versión              1.0.0          │
│ ──────────────────────────────────── │
│  Última actualización  Octubre 2025  │
└──────────────────────────────────────┘
```

**Funcionalidad**:
- **Tutorial**: Navega a la vista Help
- **Llamar a soporte**: Intenta abrir tel:+34900000000 y muestra toast

---

### 13. Help (Ayuda y Tutorial)

**Secciones**:

1. **Bienvenida**:
    - Título: "Bienvenido a Aparcabicis"
    - Descripción del servicio

2. **Guía Rápida de Inicio** (4 pasos):
   ```
   ① Busca una estación disponible
   ② Reserva una plaza (30 minutos)
   ③ Usa "Abrir puerta" para acceder
   ④ Al terminar, abre la puerta para salir
   ```

3. **Preguntas Frecuentes** (Accordion):
    - ¿Cuánto tiempo dura una reserva?
    - ¿Cómo abro la puerta?
    - ¿Qué son las estaciones favoritas?
    - ¿Cómo funciona el mapa?
    - ¿Dónde veo mi historial?
    - ¿Puedo cancelar una reserva?

4. **Características Principales**:
    - Reserva en tiempo real
    - Vista de mapa y lista
    - Sistema de favoritos
    - Control de puertas inteligente

5. **Consejos Útiles**:
    - Marca favoritas las estaciones frecuentes
    - Activa notificaciones
    - Usa filtros de búsqueda
    - Revisa tu historial

---

## 🔄 Flujos de Navegación

### Flujo 1: Login y Gestión de Cuenta
```
LoginScreen
├── Iniciar sesión → Main App
├── Menú hamburguesa
│   ├── Crear usuario → CreateUserForm → Success → LoginScreen
│   ├── Eliminar usuario → DeleteUserForm → Success → LoginScreen
│   ├── Cambiar contraseña → ChangePasswordForm → Success → LoginScreen
│   └── Recuperar contraseña → SendPasswordForm → Email enviado → LoginScreen
```

### Flujo 2: Navegación Principal
```
Main View (logged in)
├── Bottom Navigation
│   ├── Estaciones (default) → BikeStationsList / BikeStationsMap
│   ├── Historial → ReservationHistory
│   ├── Perfil → UserProfile
│   └── Ajustes → Settings → Help
```

### Flujo 3: Proceso de Reserva
```
BikeStationsList/Map
└── [Seleccionar estación]
    └── [Presionar Reservar]
        └── ActiveReservation (Estado: Reservada)
            ├── [Abrir puerta] → Cambia a "En uso"
            │   └── [Abrir puerta] (ilimitado)
            │       └── [Finalizar uso]
            │           └── Modal instrucciones
            │               └── [Click anywhere]
            │                   └── Main View
            │
            └── [Cancelar reserva]
                └── Confirmación
                    └── Main View
```

### Flujo 4: Timer de Reserva (Automático)
```
Reserva creada
└── Timer: 15:00
    ├── A los 10:00 (5 min restantes)
    │   └── Notificación de advertencia
    │
    └── A los 00:00
        └── Cancelación automática
            └── Volver a Main View
```

---

## ⚙️ Lógica de Negocio

### Sistema de Reservas

#### Crear Reserva (`handleReserve`)
```
Entrada: BikeStation

Validaciones:
1. Verificar si availableSpots > 0
2. Si no: Mostrar error "No hay plazas disponibles"

Si hay plazas:
1. Reducir availableSpots en 1
2. Setear activeReservation = station
3. Setear reservationStartTime = new Date()
4. Mostrar toast de éxito
5. Programar notificación de advertencia a los 10 minutos
```

#### Cancelar Reserva (`handleCancelReservation`)
```
1. Calcular duración = endTime - startTime (en minutos)
2. Devolver plaza: availableSpots + 1
3. Crear registro en historial:
   - status: 'completed' si duration > 0
   - status: 'cancelled' si duration = 0
4. Agregar al inicio de reservationHistory
5. Limpiar activeReservation y reservationStartTime
6. Mostrar toast con duración
```

### Sistema de Timers

#### Timer de Reserva (Estado "Reservada")
```typescript
Inicio: 15 * 60 segundos (900)
Intervalo: 1 segundo
Countdown: Decremental

Cada segundo:
  reservationTimeLeft -= 1
  
  Si reservationTimeLeft <= 0:
    Cancelar reserva automáticamente
    
Progress Bar:
  (reservationTimeLeft / 900) * 100

Notificación:
  A los 600 segundos (10 minutos):
    Toast de advertencia "Quedan 5 minutos..."
```

#### Timer de Uso (Estado "En uso")
```typescript
Inicio: 0 segundos
Intervalo: 1 segundo
Countup: Incremental
Máximo: 2 * 60 * 60 segundos (7200)

Cada segundo:
  usageTime += 1
  
  Si usageTime >= 7200:
    Detener timer
    
Progress Bar:
  (usageTime / 7200) * 100
```

### Formato de Tiempo
```typescript
function formatTime(seconds: number) {
  hours = floor(seconds / 3600)
  minutes = floor((seconds % 3600) / 60)
  secs = seconds % 60
  
  Si hours > 0:
    return "{hours}h {minutes}m {secs}s"
  Sino:
    return "{minutes}m {secs}s"
}
```

### Sistema de Favoritos

#### Toggle Favorito (`handleToggleFavorite`)
```
Entrada: stationId

Si está en favoritos:
  1. Remover de array
  2. Mostrar toast "{stationName} eliminado de favoritos"
  
Si no está en favoritos:
  1. Agregar al array
  2. Mostrar toast "{stationName} añadido a favoritos"
  
Guardar en localStorage
```

### Filtros de Búsqueda

#### BikeStationsList - Filtros
```typescript
Filtros aplicables:
1. searchQuery: Busca en name y address (case insensitive)
2. showOnlyAvailable: Filtra availableSpots > 0
3. showOnlyFavorites: Filtra si ID está en favoriteStations[]

Ordenamiento:
- 'none': Sin ordenar
- 'name': Ordenar alfabéticamente por name
- 'availability': Ordenar descendente por availableSpots

Contador de filtros activos:
  [showOnlyAvailable, showOnlyFavorites].filter(Boolean).length
```

### Cálculos de Estadísticas

#### Perfil de Usuario
```typescript
Total reservas:
  reservations.length

Tiempo total:
  reservations
    .filter(r => r.status === 'completed')
    .reduce((acc, r) => acc + r.duration, 0)
  
  Convertir a horas y minutos

Estación favorita:
  1. Contar frecuencia de cada stationName
  2. Devolver la de mayor frecuencia
  3. Si no hay reservas: "Ninguna aún"
```

#### Historial
```typescript
Total reservations: reservations.length

Completadas:
  reservations.filter(r => r.status === 'completed').length

Duración promedio:
  totalMinutes = sum(completadas.duration)
  promedio = totalMinutes / count(completadas)
  round(promedio)
```

---

## 🗄️ Estados y Gestión de Datos

### Estados Locales por Componente

#### LoginScreen
```typescript
{
  email: string
  password: string
  showPassword: boolean
  rememberMe: boolean
  isMenuOpen: boolean
  currentView: 'login' | 'create' | 'delete' | 'change' | 'send'
}
```

#### BikeStationsList
```typescript
{
  searchQuery: string
  showOnlyAvailable: boolean
  showOnlyFavorites: boolean
  isFilterOpen: boolean
  sortBy: 'name' | 'availability' | 'none'
}
```

#### BikeStationsMap
```typescript
{
  selectedStation: BikeStation | null
  userLocation: { lat: number, lng: number } | null
}
```

#### ActiveReservation
```typescript
{
  status: 'reserved' | 'in-use'
  reservationTimeLeft: number  // segundos
  usageTime: number           // segundos
  doorOpenMessage: string | null
  showFinishModal: boolean
}
```

### Estados Globales (App.tsx)
```typescript
{
  // Autenticación
  isLoggedIn: boolean
  user: { email: string } | null
  
  // Reservas
  activeReservation: BikeStation | null
  reservationStartTime: Date | null
  
  // Datos
  stations: BikeStation[]
  reservationHistory: ReservationRecord[]
  favoriteStations: string[]
  
  // Navegación
  currentView: 'main' | 'history' | 'profile' | 'settings' | 'help'
}
```

---

## 🎨 Sistema de Diseño

### Paleta de Colores

#### Color Principal
```
#7AB782 - Verde principal
Uso:
- AppBar/Header background
- Botones primarios
- Badges de disponibilidad (cuando hay plazas)
- Indicadores activos
- Progress bars
```

#### Colores Semánticos
```
- Verde (#7AB782): Disponible, éxito, activo
- Rojo: Sin disponibilidad, destructivo, error
- Azul: Reserva activa, información, links
- Amarillo: Favoritos (estrellas), advertencias
- Gris: Secundario, deshabilitado
```

#### Gradientes
```
Login/Formularios:
  from-blue-50 to-blue-100

Perfil/Settings/Help:
  from-blue-50 to-background

ActiveReservation:
  from-blue-50 to-white

Mapa:
  from-blue-100 to-green-100
```

### Tipografía

**No se especifican clases de Tailwind para tipografía** (text-2xl, font-bold, etc.)
Los estilos están definidos en `styles/globals.css` por elemento HTML.

### Espaciado

```
Padding general de contenido: p-4 (16px)
Gap entre elementos: gap-2, gap-3, gap-4
Margin de cards: mb-3, mb-4
Border radius: rounded-lg, rounded-full
```

### Componentes UI (ShadCN)

Componentes usados:
- **Accordion**: FAQs en Help
- **Alert**: Mensajes informativos
- **Badge**: Estados, contadores
- **Button**: Acciones primarias y secundarias
- **Card**: Contenedores de información
- **Checkbox**: Opción "Recuérdame"
- **Dialog**: Modales (menú hamburguesa, finalización)
- **Input**: Campos de texto
- **Label**: Etiquetas de formularios
- **Progress**: Barras de progreso (timers)
- **ScrollArea**: Listas scrolleables
- **Separator**: Divisores visuales
- **Sheet**: Panel lateral de filtros
- **Switch**: Toggles en filtros
- **Tabs**: Navegación Lista/Mapa
- **Toast (Sonner)**: Notificaciones

### Iconografía (Lucide React)

```
Bike: Logo, estaciones
Map: Vista de mapa
List: Vista de lista
MapPin: Marcadores de ubicación
Star: Favoritos
Search: Búsqueda
SlidersHorizontal: Filtros
Clock: Tiempo
Unlock: Abrir puerta
User: Perfil
Settings: Configuración
History: Historial
LogOut: Cerrar sesión
Eye/EyeOff: Mostrar/ocultar contraseña
Menu: Menú hamburguesa
Navigation: Geolocalización
Mail: Email
KeyRound: Contraseña
UserPlus/UserMinus: Crear/eliminar usuario
ArrowLeft: Volver
CheckCircle2: Éxito
Calendar: Fechas
Phone: Soporte
Info: Información
HelpCircle: Ayuda
TrendingUp: Estadísticas
```

### Animaciones

```
Pulse: 
- Marcador de ubicación en mapa
- Punto de reserva activa

Spin:
- Ninguno actualmente (se puede agregar en loaders)

Transitions:
- Hover en botones: scale-110
- Cambios de estado: fade-in/fade-out (dialogs)
```

---

## 💾 Persistencia de Datos

### LocalStorage

#### Claves utilizadas
```typescript
'bikeParking_email': string
'bikeParking_password': string  
'bikeParking_rememberMe': 'true' | null
'bikeParking_favorites': JSON string of string[]
'bikeParking_history': JSON string of ReservationRecord[]
```

#### Flujo de Carga (al iniciar)
```
useEffect(() => {
  // Cargar favoritos
  favorites = localStorage.getItem('bikeParking_favorites')
  if (favorites) setFavoriteStations(JSON.parse(favorites))
  
  // Cargar historial
  history = localStorage.getItem('bikeParking_history')
  if (history) {
    parsed = JSON.parse(history)
    // Convertir strings a Date objects
    setReservationHistory(parsed con fechas)
  }
  
  // Cargar credenciales (solo en LoginScreen)
  if (rememberMe === 'true') {
    setEmail(savedEmail)
    setPassword(savedPassword)
  }
}, [])
```

#### Flujo de Guardado
```
useEffect(() => {
  localStorage.setItem('bikeParking_favorites', 
    JSON.stringify(favoriteStations))
}, [favoriteStations])

useEffect(() => {
  localStorage.setItem('bikeParking_history', 
    JSON.stringify(reservationHistory))
}, [reservationHistory])

// Al hacer login
if (rememberMe) {
  localStorage.setItem('bikeParking_email', email)
  localStorage.setItem('bikeParking_password', password)
  localStorage.setItem('bikeParking_rememberMe', 'true')
} else {
  localStorage.removeItem('bikeParking_email')
  localStorage.removeItem('bikeParking_password')
  localStorage.removeItem('bikeParking_rememberMe')
}
```

---

## ✨ Funcionalidades Especiales

### Notificaciones (Toasts)

```typescript
Tipos usados:

toast.success(mensaje, { description?, duration? })
  - Login exitoso
  - Reserva creada
  - Favorito añadido
  - Usuario creado

toast.error(mensaje)
  - No hay plazas disponibles
  - Validaciones fallidas
  - Contraseñas no coinciden

toast.info(mensaje, { description?, duration? })
  - Sesión cerrada
  - Favorito eliminado
  - Llamando a soporte

toast.warning(mensaje, { description?, duration? })
  - 5 minutos restantes de reserva
```

### Geolocalización

```typescript
navigator.geolocation.getCurrentPosition(
  (position) => {
    userLocation = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    }
  },
  (error) => {
    console.error('Error obteniendo ubicación:', error)
  }
)
```

### Llamada a Soporte

```typescript
Tel: tel:+34900000000
window.location.href = supportPhone
```

### Responsividad

La aplicación está diseñada para **móvil first**:
- Ancho máximo de cards: max-w-md (448px)
- Layout vertical (flex-col)
- Bottom navigation fija
- Scrollable areas en listas largas

---

## 📊 Datos Mock de Ejemplo

### Estaciones
```typescript
8 estaciones en Madrid:
- Plaza Mayor (3/10 plazas)
- Estación Atocha (5/15 plazas)
- Retiro Park (0/8 plazas) - SIN DISPONIBILIDAD
- Gran Vía Centro (2/12 plazas)
- Malasaña (7/10 plazas)
- Chueca (1/6 plazas)
- Sol (4/20 plazas)
- Tribunal (6/10 plazas)

Coordenadas: Zona de Madrid (lat ~40.4, lng ~-3.7)
```

### Historial de Ejemplo
```typescript
5 reservas históricas:
- Plaza Mayor: 45 min (completada)
- Estación Atocha: 70 min (completada)
- Sol: 25 min (completada)
- Gran Vía Centro: 0 min (cancelada)
- Malasaña: 90 min (completada)
```

---

## 🚀 Implementación en Flutter

### Widgets Equivalentes

#### React → Flutter
```
Card → Card con Container
Button → ElevatedButton, OutlinedButton, TextButton
Input → TextField
Checkbox → Checkbox
Switch → Switch
Badge → Chip o Container custom
Progress → LinearProgressIndicator
Dialog → showDialog + AlertDialog/Dialog
Sheet → showModalBottomSheet
Tabs → TabBar + TabBarView
ScrollArea → ListView o SingleChildScrollView
```

### Gestión de Estado en Flutter

Recomendaciones:
```
Provider / Riverpod:
- isLoggedIn, user
- activeReservation
- stations, reservationHistory
- favoriteStations

StatefulWidget local state:
- Formularios (email, password, etc.)
- Timers (reservationTimeLeft, usageTime)
- UI toggles (showPassword, isMenuOpen, etc.)
```

### Navegación en Flutter

```dart
Navigator.pushReplacement() - Para login → main
Navigator.push() - Para vistas secundarias
Navigator.pop() - Para volver
BottomNavigationBar - Para navegación inferior

Rutas:
'/login'
'/main'
'/history'
'/profile'
'/settings'
'/help'
'/active-reservation'
'/create-user'
'/change-password'
'/delete-user'
'/send-password'
```

### Persistencia en Flutter

```dart
shared_preferences package:

await prefs.setString('bikeParking_email', email);
await prefs.setBool('bikeParking_rememberMe', true);
await prefs.setString('bikeParking_favorites', 
  jsonEncode(favoritesList));
```

### Timers en Flutter

```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  setState(() {
    if (status == 'reserved') {
      reservationTimeLeft--;
      if (reservationTimeLeft <= 0) {
        timer.cancel();
        _cancelReservation();
      }
    } else {
      usageTime++;
      if (usageTime >= maxUsageTime) {
        timer.cancel();
      }
    }
  });
});
```

### Notificaciones en Flutter

```dart
// Usando SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Reserva creada exitosamente'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);

// O usando fluttertoast package
Fluttertoast.showToast(
  msg: "Reserva creada",
  backgroundColor: Colors.green,
);
```

### Colores en Flutter

```dart
// En theme
final Color primaryColor = Color(0xFF7AB782);

// En MaterialApp
theme: ThemeData(
  primaryColor: Color(0xFF7AB782),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF7AB782),
  ),
  // ...
),
```

---

## 📝 Notas Finales

### Validaciones Importantes

1. **Reserva**:
    - Solo si availableSpots > 0
    - Solo una reserva activa a la vez

2. **Formularios**:
    - Email válido (formato)
    - Contraseña mínimo 8 caracteres
    - Confirmación de contraseñas debe coincidir

3. **Eliminación de cuenta**:
    - Debe escribir "ELIMINAR" exactamente

### Mejoras Futuras (Opcionales)

- Integración con backend real (API REST)
- Autenticación JWT
- WebSocket para disponibilidad en tiempo real
- Notificaciones push
- Pagos integrados
- Mapa real (Google Maps / Mapbox)
- Filtro por distancia real usando GPS
- Compartir ubicación de estación
- Valoraciones de estaciones
- Modo oscuro
- Múltiples idiomas

### Consideraciones de UX

- Siempre confirmar acciones destructivas (eliminar, cancelar)
- Feedback inmediato con toasts
- Estados de carga (si fuera API real)
- Mensajes de error claros
- Estados vacíos con instrucciones
- Accesibilidad (labels, contraste)

---

## 🎯 Resumen de Flujo Principal

```
1. Usuario abre app
   ↓
2. LoginScreen (o auto-login si "Recuérdame")
   ↓
3. Main View con Tabs (Lista/Mapa)
   ↓
4. Usuario busca y filtra estaciones
   ↓
5. Selecciona estación con plazas disponibles
   ↓
6. Presiona "Reservar"
   ↓
7. ActiveReservation (Estado: Reservada, 15 min)
   ↓
8. Llega a estación y presiona "Abrir puerta"
   ↓
9. Cambia a Estado: En uso (contador ascendente)
   ↓
10. Durante el uso, puede abrir/cerrar puerta ilimitadamente
    ↓
11. Al terminar, presiona "Finalizar uso"
    ↓
12. Modal con instrucciones finales
    ↓
13. Click en cualquier parte → Vuelve a Main View
    ↓
14. Reserva guardada en historial
    ↓
15. Plaza vuelve a estar disponible
```

---

**Fin de la documentación técnica**

Versión: 1.0
Fecha: Octubre 2025
Aplicación: Aparcabicis - Sistema de reserva de plazas inteligentes
