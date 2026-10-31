import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/main.dart';
import 'package:aparcabicis4/models/bootstrap_data.dart';
import 'package:aparcabicis4/models/version_check.dart';
import 'package:aparcabicis4/repositories/config_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/screens/login/login_screen.dart';
import 'package:aparcabicis4/screens/update_required_screen.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/services/version_check_service.dart';

/// Versión instalada falsa: en un test no hay canal de plataforma que
/// responda a package_info_plus.
class _FakeReader implements InstalledVersionReader {
  _FakeReader({this.build = 5, this.fails = false});

  final int build;
  final bool fails;

  @override
  Future<VersionCheckRequest> read() async {
    if (fails) throw StateError('sin plataforma');
    return VersionCheckRequest(
      platform: 'android',
      versionCode: '1.0.0',
      buildNumber: build,
    );
  }
}

/// Config repo que devuelve el JSON crudo de POST /check_version, para no
/// divergir del contrato real (specs/04-API.md).
class _FakeConfig implements ConfigRepository {
  _FakeConfig({
    this.latestBuild = 5,
    this.forceUpdate = false,
    this.fails = false,
  });

  final int latestBuild;
  final bool forceUpdate;
  final bool fails;

  VersionCheckRequest? received;

  @override
  Future<VersionCheckResult> checkVersion(VersionCheckRequest request) async {
    if (fails) throw const SocketException('sin red');
    received = request;
    return VersionCheckResult.fromJson({
      'latest_version': '2.0.0',
      'latest_build': latestBuild,
      'force_update': forceUpdate,
      'url': 'https://play.google.com/store/apps/details?id=x',
      'client_known': true,
    });
  }

  @override
  Future<BootstrapData> getBootstrap() => throw UnimplementedError();
}

void main() {
  group('comprobación de versión en el arranque (RF-A)', () {
    test('force_update=true ⇒ actualización obligatoria', () async {
      final service = VersionCheckService(
        configRepository: _FakeConfig(latestBuild: 9, forceUpdate: true),
        reader: _FakeReader(),
      );

      final decision = await service.check();

      expect(decision.action, UpdateAction.forced);
      expect(decision.latestVersion, '2.0.0');
      expect(decision.storeUrl, isNotEmpty);
    });

    test('hay build más nuevo sin forzar ⇒ aviso descartable', () async {
      final service = VersionCheckService(
        configRepository: _FakeConfig(latestBuild: 9),
        reader: _FakeReader(),
      );

      expect((await service.check()).action, UpdateAction.optional);
    });

    test('al día ⇒ no se molesta al usuario', () async {
      final service = VersionCheckService(
        configRepository: _FakeConfig(),
        reader: _FakeReader(),
      );

      expect((await service.check()).action, UpdateAction.none);
    });

    test('un build instalado por delante del publicado tampoco avisa', () async {
      // Pasa con los internos/TestFlight: no se les puede pedir "actualizar"
      // a una versión más vieja que la que ya tienen.
      final service = VersionCheckService(
        configRepository: _FakeConfig(),
        reader: _FakeReader(build: 7),
      );

      expect((await service.check()).action, UpdateAction.none);
    });

    test('manda plataforma, versión y build del binario instalado', () async {
      final config = _FakeConfig();
      await VersionCheckService(
        configRepository: config,
        reader: _FakeReader(),
      ).check();

      expect(config.received!.toJson(), {
        'platform': 'android',
        'version_code': '1.0.0',
        'build_number': 5,
      });
    });

    group('RF-A.4: un fallo de la comprobación NO deja al usuario fuera', () {
      test('si el servidor no contesta, se pasa', () async {
        final service = VersionCheckService(
          configRepository: _FakeConfig(fails: true),
          reader: _FakeReader(),
        );

        expect((await service.check()).action, UpdateAction.none);
      });

      test('si no se puede leer la versión instalada, se pasa', () async {
        final service = VersionCheckService(
          configRepository: _FakeConfig(latestBuild: 99, forceUpdate: true),
          reader: _FakeReader(fails: true),
        );

        // Aunque el backend forzaría la actualización: sin saber qué versión
        // hay instalada, bloquear sería bloquear a ciegas.
        expect((await service.check()).action, UpdateAction.none);
      });
    });
  });

  group('splash (RF-A.3, HU-1)', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      await StorageService.initialize();
    });

    Future<void> pumpApp(WidgetTester tester, VersionCheckService service) async {
      await tester.pumpWidget(
        AparcabicisApp(
          cityConfig: demoCity,
          backend: FakeBackend(
            seedParkings: demoCity.seedParkings,
            latency: Duration.zero,
          ),
          versionCheckService: service,
        ),
      );
      await tester.pump(); // primer frame: arranca la comprobación
      await tester.pump(const Duration(seconds: 3));
    }

    testWidgets('con actualización obligatoria, el splash se planta y no deja '
        'entrar', (tester) async {
      await pumpApp(
        tester,
        VersionCheckService(
          configRepository: _FakeConfig(latestBuild: 9, forceUpdate: true),
          reader: _FakeReader(),
        ),
      );

      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
      // No se ha ido al login: la app queda bloqueada de verdad.
      expect(find.byType(LoginScreen), findsNothing);

      // Y el botón "atrás" del sistema tampoco la saca de ahí.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    });

    testWidgets('si la comprobación falla, la app arranca igual (RF-A.4)',
        (tester) async {
      await pumpApp(
        tester,
        VersionCheckService(
          configRepository: _FakeConfig(fails: true),
          reader: _FakeReader(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(UpdateRequiredScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
