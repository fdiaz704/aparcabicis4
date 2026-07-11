import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/main.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/screens/login/login_screen.dart';
import 'package:aparcabicis4/screens/main/main_screen.dart';
import 'package:aparcabicis4/services/biometric_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/utils/constants.dart';

/// Biometría falsa. La real no se puede ejercitar en un emulador sin huella
/// registrada, así que estos tests cubren el **fallback a contraseña**.
class _FakeBiometrics implements BiometricAuthenticator {
  _FakeBiometrics({this.available = true, this.succeeds = true});

  final bool available;
  final bool succeeds;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async => succeeds;
}

/// Estado de una instalación con sesión guardada y biometría activada.
Future<void> givenSavedSessionWithBiometrics() async {
  SharedPreferences.setMockInitialValues({
    AppConstants.prefKeyRememberMe: 'true',
    AppConstants.prefKeyEmail: 'a@b.com',
    AppConstants.prefKeyBiometricEnabled: true,
  });
  FlutterSecureStorage.setMockInitialValues({'session_token': 'token-guardado'});
  await StorageService.initialize();
}

Widget appWith(BiometricAuthenticator biometrics) => AparcabicisApp(
      cityConfig: demoCity,
      backend: FakeBackend(
        seedParkings: demoCity.seedParkings,
        latency: Duration.zero,
      ),
      biometricAuthenticator: biometrics,
    );

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  testWidgets(
      'si la biometría falla, la app NO restaura la sesión: lleva al login y '
      'avisa de que hay que usar la contraseña', (tester) async {
    await givenSavedSessionWithBiometrics();

    await tester.pumpWidget(appWith(_FakeBiometrics(succeeds: false)));

    // Drenar el splash (2 s) y dejar que navegue.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Fallback: acaba en la pantalla de login, no en la principal.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);

    // Y se avisa al usuario de que debe entrar con la contraseña.
    expect(
      find.text('No se pudo verificar tu identidad. Inicia sesión con tu contraseña.'),
      findsOneWidget,
    );

    // El formulario de contraseña está disponible para el fallback.
    expect(find.text('Iniciar sesión'), findsWidgets);
  });

  testWidgets(
      'si el dispositivo no tiene biometría, también cae al login con '
      'contraseña', (tester) async {
    await givenSavedSessionWithBiometrics();

    await tester.pumpWidget(appWith(_FakeBiometrics(available: false)));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
  });

  testWidgets('con biometría correcta, la sesión se restaura y entra a la app',
      (tester) async {
    await givenSavedSessionWithBiometrics();

    await tester.pumpWidget(appWith(_FakeBiometrics()));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Sesión restaurada: no pasa por el login.
    expect(find.byType(LoginScreen), findsNothing);
  });
}
