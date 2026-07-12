import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/parking.dart';
import 'constants.dart';

/// Nivel de disponibilidad de un aparcamiento (RF-2.2).
///
/// `availabilityRate = plazas libres / plazas totales`:
/// verde ≥ 60 % · ámbar ≥ 20 % y < 60 % · rojo < 20 %.
enum AvailabilityLevel {
  high,
  medium,
  low;

  /// Deriva el nivel del ratio de disponibilidad.
  static AvailabilityLevel of(Parking parking) {
    if (parking.totalSpots <= 0) return AvailabilityLevel.low;
    final rate = parking.availableSpots / parking.totalSpots;
    if (rate >= 0.60) return AvailabilityLevel.high;
    if (rate >= 0.20) return AvailabilityLevel.medium;
    return AvailabilityLevel.low;
  }

  /// Color del pin para este nivel.
  ui.Color get color => switch (this) {
        AvailabilityLevel.high => AppColors.availabilityHigh,
        AvailabilityLevel.medium => AppColors.availabilityMedium,
        AvailabilityLevel.low => AppColors.availabilityLow,
      };
}

/// Construye los markers del mapa a partir de `assets/parking.svg` (RF-2.2:
/// asset propio, no el pin de Google), coloreados por disponibilidad.
///
/// **Nota sobre iOS:** el SVG original incluye un nodo `<text>` con la letra
/// "P". `flutter_svg` tiene soporte muy limitado de `<text>` y en iOS puede
/// fallar en ejecución. Por eso el nodo se **elimina antes de rasterizar** y la
/// letra se pinta con [TextPainter] sobre el mismo lienzo: el resultado es
/// idéntico en Android y iOS, sin riesgo de error.
class ParkingMarkerFactory {
  ParkingMarkerFactory({
    this.assetPath = 'assets/parking.svg',
    this.widthDp = defaultWidthDp,
  });

  final String assetPath;

  /// Ancho del marker en **píxeles lógicos** (dp). La altura se deriva sola
  /// manteniendo la proporción del SVG (66x86 ⇒ alto ≈ ancho * 1.30).
  ///
  /// El tamaño se consigue **rasterizando el PNG a los píxeles finales exactos**
  /// (widthDp x densidad de pantalla), NO pidiéndole a Google Maps que escale:
  /// en la práctica el mapa pinta el bitmap con sus píxeles crudos, así que los
  /// parámetros `imagePixelRatio`/`width` del descriptor no se pueden dar por
  /// buenos. El SVG mide 66 dp de ancho: sin esto, el marker saldría enorme.
  static const double defaultWidthDp = 28;

  final double widthDp;

  /// Color de relleno del pin en el SVG original, que se sustituye por el del
  /// nivel de disponibilidad.
  static const String _basePinColor = '#d98a3d';

  static final RegExp _textNode = RegExp(r'<text\b[^>]*>.*?</text>', dotAll: true);

  String? _rawSvg;
  final Map<AvailabilityLevel, BitmapDescriptor> _cache = {};

  /// Precarga y cachea un marker por cada nivel. Llamar una vez antes de pintar
  /// el mapa; después [markerFor] es síncrono desde caché.
  Future<void> preload({double devicePixelRatio = 3.0}) async {
    for (final level in AvailabilityLevel.values) {
      _cache[level] = await _build(level, devicePixelRatio);
    }
  }

  /// Marker ya cacheado para un aparcamiento. Si aún no se ha precargado,
  /// devuelve el pin por defecto de Google como red de seguridad.
  BitmapDescriptor markerFor(Parking parking) =>
      _cache[AvailabilityLevel.of(parking)] ?? BitmapDescriptor.defaultMarker;

  /// Markers del mapa: uno por aparcamiento, con el pin del color que le toca
  /// por disponibilidad (RF-2.2).
  ///
  /// Vive aquí y no en la pantalla para poder comprobarlo en un test: montar un
  /// `GoogleMap` de verdad exige la vista nativa de la plataforma, que en un
  /// test no existe.
  Set<Marker> markersFor(
    Iterable<Parking> parkings, {
    required String Function(Parking parking) snippet,
    required void Function(Parking parking) onTap,
  }) {
    return parkings
        .map(
          (parking) => Marker(
            markerId: MarkerId(parking.id),
            position: LatLng(parking.lat, parking.lng),
            icon: markerFor(parking),
            infoWindow: InfoWindow(
              title: parking.name,
              snippet: snippet(parking),
            ),
            onTap: () => onTap(parking),
          ),
        )
        .toSet();
  }

  Future<BitmapDescriptor> _build(
    AvailabilityLevel level,
    double devicePixelRatio,
  ) async {
    final svg = await _svgFor(level);

    final pictureInfo = await vg.loadPicture(SvgStringLoader(svg), null);
    final size = pictureInfo.size;

    // Google Maps pinta el bitmap con sus píxeles crudos e ignora las pistas de
    // escalado (imagePixelRatio/width). Así que NO le pedimos que lo encoja:
    // rasterizamos ya al tamaño final exacto.
    //
    //   píxeles finales = ancho deseado (dp) x densidad de la pantalla
    //
    // De este modo el marker mide [widthDp] dp pase lo que pase, y sigue nítido
    // porque se dibuja a la resolución real del dispositivo.
    final targetWidthPx = widthDp * devicePixelRatio;
    final scale = targetWidthPx / size.width;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);

    // La "P", pintada aquí en vez de con <text> (ver nota de iOS en la clase).
    _paintLetter(canvas, size, level.color);

    final image = await recorder.endRecording().toImage(
          (size.width * scale).round(),
          (size.height * scale).round(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    pictureInfo.picture.dispose();
    image.dispose();

    // imagePixelRatio = densidad de pantalla ⇒ si el plugin SÍ lo respeta,
    // el resultado es el mismo tamaño. Ambos caminos coinciden.
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
  }

  /// SVG del asset, sin el nodo `<text>` y con el pin recoloreado.
  Future<String> _svgFor(AvailabilityLevel level) async {
    final raw = _rawSvg ??= await rootBundle.loadString(assetPath);
    final hex = _toHex(level.color);
    return raw.replaceAll(_textNode, '').replaceAll(_basePinColor, hex);
  }

  /// Dibuja la "P" centrada en el círculo del pin.
  void _paintLetter(ui.Canvas canvas, ui.Size size, ui.Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'P',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.45,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // El círculo blanco del SVG está centrado en (33, 31) de un lienzo 66x86.
    final center = ui.Offset(size.width / 2, size.height * (31 / 86));
    painter.paint(
      canvas,
      center - ui.Offset(painter.width / 2, painter.height / 2),
    );
  }

  static String _toHex(ui.Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}
