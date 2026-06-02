# Decisiones de diseño — respuestas al diagnóstico API vs. app

> Documento para rellenar antes de pedir a Cowork el contrato de API y el esquema.
> Origen: sección 4 del diagnóstico (`diagnostico-api-vs-app.md`), 11 decisiones.
> Organizado por quién resuelve cada cosa, no por el orden del diagnóstico.

---

## GRUPO A — Decisiones de producto (las resuelves tú, rápido)

### A1. Favoritos: ¿locales o sincronizados? (decisión #6)
Hoy son 100% locales (`SharedPreferences`). Sincronizarlos entre dispositivos exige
tabla + endpoints + identidad de usuario.
- [X] Locales por dispositivo (sin cambios en la API)
- [ ] Sincronizados (tabla `favoritos` + endpoints, depende de A-grupo-auth)

**Respuesta:**

Locales por dispoisitivo (sin cambios en la API)


### A2. Tarifa real para estadísticas (decisión #7, parte de métricas)
Hoy el "ahorro" asume 2 €/h inventados.
- ¿Hay tarifa real? ¿Cuál? ¿O el servicio es gratuito y se quita el "ahorro"? 

**Respuesta:**

El servicio es gratuito y se quita el ahorro



### A3. Plaza con/sin enchufe expuesta al usuario (decisión #5)
La API ya distingue tipo de plaza (`Tipo_lock`/`pla_elect`: 0 sin enchufe / 1 con / 2 indistinto).
La app hoy no lo contempla.
- [ ] Sí, el usuario elige plaza con enchufe al reservar (añadir al modelo + pantalla)
- [ ] No, indiferente en v1 (la API autoselecciona)

**Respuesta:**

No, indiferentes en v1


### A4. Historial: ¿autoritativo del servidor o local? (decisión #7, parte historial)
Hoy local (`SharedPreferences`). El servidor tiene los datos en `LOG_SESIONES`/`DATALOG`.
- [ ] Servidor (multi-dispositivo) — reconstruido desde `LOG_SESIONES` o tabla nueva
- [ ] Local (se queda como está)

**Respuesta:**

Servidor (multi-dispositivo) - reconstruidos desde LOG_SESIONES


### A5. Push (FCM/APNs): ¿entra en v1 o se difiere? (decisión #10)
Avisos de 5 min, expiración, sanción. Hoy no hay nada de push en la API.
- [ ] Entra en v1 (tabla de tokens de dispositivo + disparadores)
- [ ] Se difiere a una versión posterior

**Respuesta:**

Se difiere a una versión posterior

---

## GRUPO B — Datos/recursos externos que hay que conseguir (no es decidir, es aportar)

### B1. ⭐ Catálogo de estaciones con coordenadas (decisión #2) — EL MÁS BLOQUEANTE
Hoy NO existe en ninguna tabla: ni nombre, ni dirección, ni latitud/longitud, ni capacidad
total por locker. Sin esto NO hay lista de estaciones, NI mapa, NI marcadores.
- ¿De dónde salen nombre, dirección, lat/lng y total de plazas de cada locker (`pla_apbid`)?
- ¿Existe una hoja/fuente maestra para cargarlos, o se introducen a mano?
- ¿Cuántos lockers hay hoy en producción?

**Respuesta:**

De la tabla APARCABICIS


### B2. SMTP de producción (decisión #11)
Las credenciales del repo son de pruebas y están en claro. Para recuperación de
contraseña y avisos hace falta SMTP real.
- ¿Proveedor y credenciales oficiales? (no las pegues aquí en claro — solo confirma que existen
  y dónde se guardarán: variable de entorno / fichero de secrets)

**Respuesta:**

Existen

---

## GRUPO C — Decisión técnica que reabre el ADR (pregunta al equipo de hardware)

### C1. ⭐⭐ Sensor de puerta `pla_puerta_st` (decisión #4) — LA QUE CONDICIONA TODO
El ADR dice "hardware unidireccional puro, sin telemetría". Pero el código revela un canal:
la columna `pla_puerta_st` y el endpoint `sensado_puertas`, por el que un sistema "Control"
escribe el estado físico de la puerta, y `end_sesion` ya lo usa.
**Preguntas al equipo de hardware:**
- ¿`pla_puerta_st` es fiable?
- ¿Está disponible en TODAS las plazas que usará la app, o solo en algunas?
- ¿Es del sistema actual o de un subsistema viejo/parcial?

Según la respuesta:
- [ ] Es fiable y universal → revisar el ADR: el enlace NO es unidireccional puro; la app
      puede mostrar estado de puerta y ocupación más veraz.
- [ ] No es fiable / es de otro subsistema → mantener el ADR (disponibilidad derivada de
      reservas) y documentar que `pla_puerta_st` no se expone a la app.

**Respuesta:**

Es fiable y universal


### C2. Planificador de expiración/sanción (decisión #8)
El ADR exige que la expiración de reserva (30 min) y la sanción (14 h) sean autoritativas
del servidor. El diagnóstico no encontró un cron/Event Scheduler que las dispare; hoy la
app lo hace con `Timer.periodic` (incorrecto en producción).
**Pregunta (parte hardware/infra, parte tú):**
- ¿Existe ya un cron / Event Scheduler en el servidor que libere reservas caducadas y
  dispare la sanción de 14 h, o hay que crearlo?

**Respuesta:**

Si existe controlado con redis
---

## GRUPO D — Decisiones del módulo de auth (relacionadas, decídelas juntas)

> El diagnóstico reveló que la API NO autentica usuarios finales, solo a la app como cliente.
> Todo el módulo de cuentas hay que construirlo. Estas tres decisiones van juntas.

### D1. Modelo de identidad (decisión #1)
- ¿Identidad propia con contraseña gestionada por el backend (bcrypt/argon2 + JWT, como el ADR)?
  (Se asume que sí, salvo que decidas otra cosa.)

**Respuesta:**

Identidad propia con contraseña gestionada por el backend


### D2. Verificación de email y política de alta (decisión #1 + #3 registro)
- ¿Auto-registro abierto desde la app?
- ¿Verificación por email obligatoria antes de poder usar la cuenta?
- ¿Unicidad por correo?

**Respuesta:**

Aquí depende de la ciudad. Por ejemplo vamos a implementar en Palma y en Alcorcón. En Palma el registro es previo y en Alcorcón es registro es por ciudad. Vamos a comenzar por Palma

### D3. 2FA / TOTP (decisión #1)
El ADR lo menciona. ¿En v1 o diferido?
- [ ] En v1
- [ ] Diferido a versión posterior

**Respuesta:**
Diferido a versión posterior

### D4. Borrado de cuenta y retención GDPR (decisión #9)
Hoy solo existe baja administrativa (sanción), no borrado a petición del usuario.
- ¿Borrado físico o anonimización?
- ¿Plazo legal de conservación de logs (`DATALOG`/`LOG_SESIONES`)?

**Respuesta:**
Borrado físico
---

## Nota aparte (NO es una de las 11, pero no la pierdas)
Deuda de seguridad en la API existente: varios endpoints legacy concatenan SQL directamente
(inyección SQL) y hay credenciales de BD/SMTP en claro en el repo. No bloquea el diseño, pero
es código en producción con datos personales bajo LOPD. Planificar su corrección.

Para modificación posterior