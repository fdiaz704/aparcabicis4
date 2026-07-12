import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/providers/parkings_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_parkings_repository.dart';
import 'package:aparcabicis4/services/location_service.dart';
import 'package:aparcabicis4/services/route_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';

/// Sol (40.4168, -3.7038) es uno de los aparcamientos del seed demo.
const _puertaDelSol = UserLocation(lat: 40.4168, lng: -3.7038);

void main() {
  late ParkingsProvider provider;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();

    provider = ParkingsProvider(
      parkingsRepository: FakeParkingsRepository(
        FakeBackend(
          seedParkings: demoCity.seedParkings,
          latency: Duration.zero,
        ),
      ),
    );
    await provider.initialize();
  });

  group('distancias y cercanos (RF-2.5 / RF-2.7)', () {
    test('sin ubicación conocida no hay distancias', () {
      expect(provider.userLocation, isNull);
      expect(provider.distanceTo(provider.parkings.first), isNull);
    });

    test('con ubicación, calcula la distancia a cada aparcamiento', () {
      provider.setUserLocation(_puertaDelSol);

      final sol = provider.parkings.firstWhere((p) => p.name == 'Sol');
      // El propio Sol está a metros de la posición.
      expect(provider.distanceTo(sol)!, lessThan(50));

      final atocha =
          provider.parkings.firstWhere((p) => p.name == 'Aparcamiento Atocha');
      // Atocha está a algo más de 1 km de Sol.
      expect(provider.distanceTo(atocha)!, greaterThan(800));
    });

    test('nearestParkings ordena de más cerca a más lejos', () {
      provider.setUserLocation(_puertaDelSol);

      final nearest = provider.nearestParkings;
      expect(nearest.first.name, 'Sol');

      // La lista queda ordenada por distancia creciente.
      final distances =
          nearest.map((p) => provider.distanceTo(p)!).toList();
      final sorted = List<double>.from(distances)..sort();
      expect(distances, sorted);
    });

    test('el orden por distancia solo aplica si hay ubicación (RF-2.7)', () {
      provider.setFilters(sortBy: 'distance');

      // Sin ubicación, no reordena (y no revienta).
      final withoutLocation = provider.getFilteredParkings();
      expect(withoutLocation.length, demoCity.seedParkings.length);

      provider.setUserLocation(_puertaDelSol);
      final withLocation = provider.getFilteredParkings();
      expect(withLocation.first.name, 'Sol');
    });
  });

  group('EstimatedRouteService (estimación sin coste)', () {
    test('devuelve una ruta con ETA y distancia coherentes', () async {
      const service = EstimatedRouteService();

      // Sol → Atocha, ~1,2 km en línea recta.
      final route = await service.getRoute(
        origin: const LatLng(40.4168, -3.7038),
        destination: const LatLng(40.4064, -3.6910),
      );

      expect(route, isNotNull);
      // No aporta polyline: es una estimación, no un recorrido real por calles.
      expect(route!.points, isEmpty);
      expect(route.distanceMeters, greaterThan(1000));
      // A 15 km/h, ~1,5 km son unos 6 minutos.
      expect(route.eta.inMinutes, inInclusiveRange(3, 12));
    });

    test('a mayor distancia, mayor ETA', () async {
      const service = EstimatedRouteService();
      const origin = LatLng(40.4168, -3.7038);

      final near = await service.getRoute(
        origin: origin,
        destination: const LatLng(40.4200, -3.7038),
      );
      final far = await service.getRoute(
        origin: origin,
        destination: const LatLng(40.5000, -3.7038),
      );

      expect(far!.eta, greaterThan(near!.eta));
    });
  });

  group('aviso de ETA (HU-4)', () {
    test('un ETA mayor que la ventana de reserva debe avisar', () async {
      const service = EstimatedRouteService();
      const windowMin = 30; // ventana del bootstrap

      // Destino muy lejano: el ETA en bici supera de largo los 30 min.
      final route = await service.getRoute(
        origin: const LatLng(40.4168, -3.7038),
        destination: const LatLng(40.9000, -3.7038),
      );

      expect(route!.eta.inMinutes, greaterThan(windowMin));
    });

    test('un aparcamiento cercano NO dispara el aviso', () async {
      const service = EstimatedRouteService();
      const windowMin = 30;

      final route = await service.getRoute(
        origin: const LatLng(40.4168, -3.7038),
        destination: const LatLng(40.4200, -3.7038),
      );

      expect(route!.eta.inMinutes, lessThanOrEqualTo(windowMin));
    });
  });

  group('factor de rodeo del ETA (HU-4)', () {
    test('la distancia estimada aplica el factor sobre la línea recta', () async {
      const straightOnly = EstimatedRouteService(detourFactor: 1.0);
      const withDetour = EstimatedRouteService(); // 1.30 por defecto

      const origin = LatLng(40.4168, -3.7038);
      const destination = LatLng(40.4239, -3.6968);

      final straight = await straightOnly.getRoute(
        origin: origin,
        destination: destination,
      );
      final real = await withDetour.getRoute(
        origin: origin,
        destination: destination,
      );

      // El recorrido estimado es un 30 % más largo que la recta.
      expect(
        real!.distanceMeters / straight!.distanceMeters,
        closeTo(EstimatedRouteService.defaultDetourFactor, 0.02),
      );
    });

    test(
        'un factor MAYOR da un ETA mayor: errar por exceso es lo seguro, porque '
        'quedarse corto haría perder la reserva sin avisar', () async {
      const conservative = EstimatedRouteService(detourFactor: 1.40);
      const optimistic = EstimatedRouteService(detourFactor: 1.15);

      const origin = LatLng(40.4168, -3.7038);
      const destination = LatLng(40.5000, -3.7038);

      final safe = await conservative.getRoute(
        origin: origin,
        destination: destination,
      );
      final risky = await optimistic.getRoute(
        origin: origin,
        destination: destination,
      );

      expect(safe!.eta, greaterThan(risky!.eta));
    });
  });
}
