import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/main.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/screens/login/login_screen.dart';
import 'package:aparcabicis4/screens/main/main_screen.dart';
import 'package:aparcabicis4/services/biometric_service.dart';
import 'package:aparcabicis4/services/navigation_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/utils/constants.dart';

import 'support/version_check_doubles.dart';

/// Biometría falsa con guion: cada authenticate consume el siguiente
/// resultado de [script]; agotado el guion, repite el último.
class _ScriptedBiometrics implements BiometricAuthenticator {
  _ScriptedBiometrics(this.script);

  final List<bool> script;
  int authenticateCalls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    final i = authenticateCalls < script.length
        ? authenticateCalls
        : script.length - 1;
    authenticateCalls++;
    return script[i];
  }
}

/// Instalación con sesión guardada y biometría activada (estado del usuario
/// que reportó el fallo: cerró sesión y no se le pidió la huella).
Future<void> givenSavedSessionWithBiometrics() async {
  SharedPreferences.setMockInitialValues({
    AppConstants.prefKeyRememberMe: 'true',
    AppConstants.prefKeyEmail: 'a@b.com',
    AppConstants.prefKeyBiometricEnabled: true,
  });
  FlutterSecureStorage.setMockInitialValues({
    'session_token': 'token',
    'refresh_token': 'refresh',
  });
  await StorageService.initialize();
}

Widget appWith(BiometricAuthenticator biometrics) {
  final backend = FakeBackend(
    seedParkings: demoCity.seedParkings,
    latency: Duration.zero,
  );
  return AparcabicisApp(
    cityConfig: demoCity,
    backend: backend,
    biometricAuthenticator: biometrics,
    versionCheckService: upToDateVersionCheck(backend),
  );
}

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  testWidgets(
      'FLUJO REPORTADO: cerrar sesión con la X deja la sesión bloqueada, el '
      'login dispara la huella SOLO y, si falla, quedan botón y contraseña',
      (tester) async {
    await givenSavedSessionWithBiometrics();

    // Guion: 1ª huella (splash) OK → entra; 2ª (auto-prompt tras logout)
    // falla → se queda en el login con las alternativas visibles.
    final biometrics = _ScriptedBiometrics([true, false]);
    await tester.pumpWidget(appWith(biometrics));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(MainScreen), findsOneWidget);
    expect(biometrics.authenticateCalls, 1);

    // Cerrar sesión con la X de la barra superior.
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    // Al llegar al login, la huella se solicitó AUTOMÁTICAMENTE (2ª llamada).
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(biometrics.authenticateCalls, 2);

    // Falló/canceló: quedan el reintento con huella, el olvido del
    // dispositivo y el formulario de contraseña como fallback.
    expect(find.text('Entrar con huella'), findsOneWidget);
    expect(find.text('Olvidar este dispositivo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);

    // Reintento con huella (3ª llamada, el guion repite false → true no:
    // repite el último = false). Se reintenta una vez más para cubrir el
    // camino del botón.
    biometrics.script
      ..clear()
      ..add(true);
    biometrics.authenticateCalls = 0;
    await tester.ensureVisible(find.text('Entrar con huella'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar con huella'));
    await tester.pumpAndSettle();

    // Huella correcta: la sesión se reabre sin contraseña.
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets(
      'el logout desde "Usar contraseña" del bloqueo NO re-dispara la huella '
      'en el login (el usuario pidió contraseña explícitamente)',
      (tester) async {
    await givenSavedSessionWithBiometrics();

    final biometrics = _ScriptedBiometrics([true]);
    await tester.pumpWidget(appWith(biometrics));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);

    // Se reproduce el mismo camino que AppLockGate._usePassword: logout sin
    // re-prompt y navegación al login.
    final context = tester.element(find.byType(MainScreen));
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await tester.runAsync(
      () => authProvider.logout(offerBiometricRelogin: false),
    );

    biometrics.authenticateCalls = 0;
    NavigationService.pushNamedAndClearStack(AppRoutes.login);
    await tester.pumpAndSettle();

    // En el login no se disparó la huella automáticamente.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(biometrics.authenticateCalls, 0);
    // Pero el botón de reentrada sí está disponible.
    expect(find.text('Entrar con huella'), findsOneWidget);
  });
}
