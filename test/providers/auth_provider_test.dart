import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_auth_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/services/biometric_service.dart';
import 'package:aparcabicis4/services/secure_storage_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/utils/constants.dart';

/// Biometría falsa: la real no es ejercitable en un emulador sin huella
/// registrada, así que se inyecta para poder probar el camino de éxito y,
/// sobre todo, el **fallback a contraseña**.
class _FakeBiometrics implements BiometricAuthenticator {
  _FakeBiometrics({this.available = true, this.succeeds = true});

  final bool available;
  final bool succeeds;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async => succeeds;
}

AuthProvider buildProvider({BiometricAuthenticator? biometrics}) {
  final backend = FakeBackend(
    seedParkings: demoCity.seedParkings,
    latency: Duration.zero,
  );
  return AuthProvider(
    authRepository: FakeAuthRepository(backend),
    biometricAuthenticator: biometrics ?? _FakeBiometrics(),
  );
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await StorageService.initialize();
  });

  group('login', () {
    test('rechaza email inválido o contraseña corta', () async {
      final provider = buildProvider();
      expect(await provider.login('no-es-email', 'password123', false), isFalse);
      expect(await provider.login('a@b.com', 'corta', false), isFalse);
      expect(provider.isLoggedIn, isFalse);
    });

    test('acepta credenciales válidas y guarda los tokens de forma segura',
        () async {
      final provider = buildProvider();
      expect(await provider.login('a@b.com', 'password123', false), isTrue);

      expect(provider.isLoggedIn, isTrue);
      expect(provider.user!.email, 'a@b.com');
      expect(await SecureStorageService.getSessionToken(), isNotNull);
      expect(await SecureStorageService.getRefreshToken(), isNotNull);
    });
  });

  group('seguridad de credenciales (RF-1.3)', () {
    test('la contraseña NO se persiste en ningún sitio', () async {
      final provider = buildProvider();
      await provider.login('a@b.com', 'password123', true);

      final prefs = await SharedPreferences.getInstance();
      // Ni la clave heredada ni ninguna otra contienen la contraseña.
      expect(prefs.containsKey(AppConstants.prefKeyLegacyPassword), isFalse);
      for (final key in prefs.getKeys()) {
        expect(prefs.get(key).toString(), isNot(contains('password123')));
      }
    });

    test('purga la contraseña heredada en claro al arrancar', () async {
      // Instalación antigua que guardaba la contraseña en claro.
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyLegacyPassword: 'secreto-en-claro',
      });
      await StorageService.initialize();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(AppConstants.prefKeyLegacyPassword), isFalse);
    });
  });

  group('"Recuérdame" = mantener sesión', () {
    test('con Recuérdame, la sesión se restaura al arrancar', () async {
      await buildProvider().login('a@b.com', 'password123', true);

      // Nuevo arranque de la app.
      final restored = buildProvider();
      await restored.initialize();

      expect(restored.isLoggedIn, isTrue);
      expect(restored.user!.email, 'a@b.com');
    });

    test('sin Recuérdame, no se mantiene la sesión y se destruyen los tokens',
        () async {
      await buildProvider().login('a@b.com', 'password123', false);

      final restored = buildProvider();
      await restored.initialize();

      expect(restored.isLoggedIn, isFalse);
      expect(await SecureStorageService.getSessionToken(), isNull);
    });
  });

  group('biometría (RF-1.6)', () {
    test('con biometría correcta, la sesión se restaura', () async {
      final provider = buildProvider();
      await provider.login('a@b.com', 'password123', true);
      expect(await provider.enableBiometrics('motivo'), isTrue);
      expect(provider.isBiometricEnabled, isTrue);

      final restored = buildProvider();
      await restored.initialize(biometricReason: 'motivo');

      expect(restored.isLoggedIn, isTrue);
      expect(restored.biometricFallbackRequired, isFalse);
    });

    test(
        'si la biometría falla, NO se restaura la sesión y se pide contraseña '
        '(fallback)', () async {
      final provider = buildProvider();
      await provider.login('a@b.com', 'password123', true);
      await provider.enableBiometrics('motivo');

      // Nuevo arranque: el usuario no supera la verificación biométrica.
      final restored =
          buildProvider(biometrics: _FakeBiometrics(succeeds: false));
      await restored.initialize(biometricReason: 'motivo');

      expect(restored.isLoggedIn, isFalse);
      expect(restored.biometricFallbackRequired, isTrue);
    });

    test(
        'si el dispositivo no tiene biometría, tampoco se restaura: fallback a '
        'contraseña', () async {
      final provider = buildProvider();
      await provider.login('a@b.com', 'password123', true);
      await provider.enableBiometrics('motivo');

      final restored =
          buildProvider(biometrics: _FakeBiometrics(available: false));
      await restored.initialize(biometricReason: 'motivo');

      expect(restored.isLoggedIn, isFalse);
      expect(restored.biometricFallbackRequired, isTrue);
    });

    test('no se puede activar la biometría si el dispositivo no la soporta',
        () async {
      final provider = buildProvider(
        biometrics: _FakeBiometrics(available: false),
      );
      expect(await provider.enableBiometrics('motivo'), isFalse);
      expect(provider.isBiometricEnabled, isFalse);
    });
  });

  test('logout destruye los tokens de sesión', () async {
    final provider = buildProvider();
    await provider.login('a@b.com', 'password123', true);

    await provider.logout();

    expect(provider.isLoggedIn, isFalse);
    expect(await SecureStorageService.getSessionToken(), isNull);
  });
}
