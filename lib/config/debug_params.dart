import 'package:flutter/foundation.dart';

import '../models/app_params.dart';

/// Activa tiempos cortos para poder **ver los avisos dispararse** sin esperar
/// media hora:
///
/// ```bash
/// flutter run --flavor demo --dart-define=CITY=demo --dart-define=FAST_TIMES=true
/// ```
///
/// Solo tiene efecto en **debug**: un build de release lo ignora, pase lo que
/// pase, para que no se cuele en producción.
const bool _fastTimesRequested =
    bool.fromEnvironment('FAST_TIMES');

bool get fastTimesEnabled => kDebugMode && _fastTimesRequested;

/// Parámetros comprimidos para pruebas.
///
/// No se usa un "factor de compresión" del reloj porque los offsets de aviso
/// son **minutos enteros**: comprimir 30x los dejaría en segundos, que ni
/// [AppParams] puede representar ni las alarmas del sistema garantizan. Se
/// sirven directamente parámetros cortos, que es lo que sí funciona.
///
/// Equivalencias con los reales. Se dejan holgados a propósito: con series muy
/// apretadas los avisos se pisan unos a otros y no da tiempo ni a leerlos.
/// - ventana de reserva: 30' → 8'   (avisos a 5' y 2' en vez de 10' y 5')
/// - uso máximo:        840' → 12'  (avisos a 6', 4' y 2')
/// - aviso de exceso:    30' → 3'
const AppParams fastParams = AppParams(
  reservationWindowMin: 8,
  maxUseMin: 12,
  reservationWarningsMin: [5, 2],
  useWarningsMin: [6, 4, 2],
  overstayIntervalMin: 3,
);

/// Parámetros que debe servir el backend simulado.
AppParams resolveFakeParams() =>
    fastTimesEnabled ? fastParams : AppParams.defaults;
