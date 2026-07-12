import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aparcabicis4/models/parking.dart';
import 'package:aparcabicis4/utils/constants.dart';
import 'package:aparcabicis4/utils/parking_marker_factory.dart';

Parking parkingWith({required int available, required int total}) => Parking(
      id: 'p',
      name: 'Test',
      address: 'Calle Test',
      availableSpots: available,
      totalSpots: total,
      lat: 0,
      lng: 0,
    );

void main() {
  group('umbrales de disponibilidad (RF-2.2)', () {
    test('verde cuando hay ≥60 % de plazas libres', () {
      // 6/10 = 60 % justo en el límite.
      expect(
        AvailabilityLevel.of(parkingWith(available: 6, total: 10)),
        AvailabilityLevel.high,
      );
      expect(
        AvailabilityLevel.of(parkingWith(available: 10, total: 10)),
        AvailabilityLevel.high,
      );
    });

    test('ámbar cuando hay ≥20 % y <60 %', () {
      // 2/10 = 20 % justo en el límite inferior.
      expect(
        AvailabilityLevel.of(parkingWith(available: 2, total: 10)),
        AvailabilityLevel.medium,
      );
      // 5/10 = 50 %, justo por debajo del 60 %.
      expect(
        AvailabilityLevel.of(parkingWith(available: 5, total: 10)),
        AvailabilityLevel.medium,
      );
    });

    test('rojo cuando hay <20 %', () {
      // 1/10 = 10 %.
      expect(
        AvailabilityLevel.of(parkingWith(available: 1, total: 10)),
        AvailabilityLevel.low,
      );
      // Sin plazas libres.
      expect(
        AvailabilityLevel.of(parkingWith(available: 0, total: 10)),
        AvailabilityLevel.low,
      );
    });

    test('un aparcamiento sin plazas totales se trata como rojo', () {
      expect(
        AvailabilityLevel.of(parkingWith(available: 0, total: 0)),
        AvailabilityLevel.low,
      );
    });

    test('cada nivel tiene su color', () {
      expect(AvailabilityLevel.high.color, AppColors.availabilityHigh);
      expect(AvailabilityLevel.medium.color, AppColors.availabilityMedium);
      expect(AvailabilityLevel.low.color, AppColors.availabilityLow);
    });
  });

  group('rasterización del marker (assets/parking.svg)', () {
    testWidgets(
        'genera un marker por nivel a partir del SVG, sin usar el nodo <text> '
        '(que rompe en iOS)', (tester) async {
      final factory = ParkingMarkerFactory();

      // La rasterización usa el motor gráfico: fuera del zone simulado.
      await tester.runAsync(() async {
        await factory.preload(devicePixelRatio: 2);
      });

      // Cada nivel devuelve su propio marker (no el pin por defecto de Google).
      final high = factory.markerFor(parkingWith(available: 8, total: 10));
      final medium = factory.markerFor(parkingWith(available: 3, total: 10));
      final low = factory.markerFor(parkingWith(available: 0, total: 10));

      for (final marker in [high, medium, low]) {
        expect(marker, isNotNull);
        expect(
          marker,
          isNot(BitmapDescriptor.defaultMarker),
          reason: 'debe usar el asset propio, no el pin de Google (RF-2.2)',
        );
      }

      // Los tres niveles producen imágenes distintas (colores distintos).
      expect(high, isNot(equals(medium)));
      expect(medium, isNot(equals(low)));
    });
  });
}
