import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/models/reservation.dart';
import 'package:aparcabicis4/models/version_check.dart';
import 'package:aparcabicis4/providers/session_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_auth_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_config_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_reservations_repository.dart';
import 'package:aparcabicis4/repositories/repository_exception.dart';
import 'package:aparcabicis4/services/storage_service.dart';

void main() {
  late FakeBackend backend;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.initialize();

    backend = FakeBackend(
      seedParkings: demoCity.seedParkings,
      latency: Duration.zero,
    );
  });

  group('bootstrap (RF-B)', () {
    test('sin sesión iniciada, el bootstrap falla con UNAUTHENTICATED',
        () async {
      final provider =
          SessionProvider(configRepository: FakeConfigRepository(backend));

      expect(await provider.load(), isNull);
      expect(provider.errorCode, RepositoryErrorCodes.unauthenticated);
    });

    test('devuelve perfil, parámetros del sistema y sin reserva en curso',
        () async {
      await FakeAuthRepository(backend)
          .login(email: 'a@b.com', password: 'password123');

      final provider =
          SessionProvider(configRepository: FakeConfigRepository(backend));
      final data = await provider.load();

      expect(data, isNotNull);
      expect(provider.user!.email, 'a@b.com');

      // Los tiempos vienen del backend, no de constantes de la app (RF-B.2).
      expect(provider.params.reservationWindowMin, 30);
      expect(provider.params.maxUseMin, 840);
      expect(provider.params.reservationWarningsMin, [10, 5]);
      expect(provider.params.useWarningsMin, [30, 15, 5]);
      expect(provider.params.overstayIntervalMin, 30);

      expect(provider.currentReservation, isNull);
      expect(provider.hasOngoingReservation, isFalse);
    });

    test('si hay uso en curso, el bootstrap lo devuelve (RF-B.3)', () async {
      await FakeAuthRepository(backend)
          .login(email: 'a@b.com', password: 'password123');

      final parking =
          demoCity.seedParkings.firstWhere((p) => p.availableSpots > 0);
      await FakeReservationsRepository(backend).createReservation(parking.id);

      final provider =
          SessionProvider(configRepository: FakeConfigRepository(backend));
      await provider.load();

      expect(provider.hasOngoingReservation, isTrue);
      expect(provider.currentReservation!.status, ReservationStatus.pending);
      expect(provider.currentReservation!.parkingId, parking.id);
    });
  });

  group('POST /check_version (RF-A.2)', () {
    test('respeta el contrato real: latest_version, latest_build, force_update, '
        'url, client_known', () async {
      final repo = FakeConfigRepository(
        backend,
        latestVersion: '1.2.0',
        latestBuild: 7,
        forceUpdate: true,
        updateUrl: 'https://play.google.com/store/apps/details?id=demo',
      );

      final result = await repo.checkVersion(
        const VersionCheckRequest(
          platform: 'android',
          versionCode: '1.0.0',
          buildNumber: 1,
        ),
      );

      expect(result.latestVersion, '1.2.0');
      expect(result.latestBuild, 7);
      expect(result.forceUpdate, isTrue);
      expect(result.url, 'https://play.google.com/store/apps/details?id=demo');
      expect(result.clientKnown, isTrue);

      // Hay versión más reciente que la instalada (build 1).
      expect(result.isOutdated(1), isTrue);
      expect(result.isOutdated(7), isFalse);

      // Las claves JSON son exactamente las del endpoint (snake_case).
      expect(result.toJson().keys, containsAll(<String>[
        'latest_version',
        'latest_build',
        'force_update',
        'url',
        'client_known',
      ]));
    });

    test('la petición se serializa con las claves del contrato', () {
      const request = VersionCheckRequest(
        platform: 'ios',
        versionCode: '1.0.0',
        buildNumber: 3,
      );

      expect(request.toJson(), {
        'platform': 'ios',
        'version_code': '1.0.0',
        'build_number': 3,
      });
    });
  });
}
