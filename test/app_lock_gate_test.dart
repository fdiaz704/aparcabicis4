import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/l10n/app_localizations.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_auth_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/services/biometric_service.dart';
import 'package:aparcabicis4/services/storage_service.dart';
import 'package:aparcabicis4/utils/constants.dart';
import 'package:aparcabicis4/widgets/app_lock_gate.dart';

class _FakeBiometrics implements BiometricAuthenticator {
  _FakeBiometrics({this.succeeds = true});

  final bool succeeds;
  int authenticateCalls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    authenticateCalls++;
    return succeeds;
  }
}

/// Más que el margen de gracia configurado en la app.
const Duration _beyondGrace =
    Duration(seconds: AppConstants.biometricLockGraceSeconds + 5);

void main() {
  /// Reloj controlado: dentro de un widget test el tiempo real no avanza, así
  /// que el gate recibe este reloj y lo movemos nosotros.
  late DateTime now;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    now = DateTime(2026, 7, 12, 12);
  });

  /// Prepara una instalación con sesión abierta.
  ///
  /// Se ejecuta con [WidgetTester.runAsync] porque toca canales de plataforma
  /// (SharedPreferences y almacenamiento seguro), que cuelgan si se esperan
  /// dentro del zone asíncrono simulado de `testWidgets`.
  Future<AuthProvider> givenLoggedInSession(
    WidgetTester tester, {
    required _FakeBiometrics biometrics,
    required bool biometricEnabled,
  }) async {
    late AuthProvider provider;

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyRememberMe: 'true',
        AppConstants.prefKeyEmail: 'a@b.com',
        AppConstants.prefKeyBiometricEnabled: biometricEnabled,
      });
      FlutterSecureStorage.setMockInitialValues({
        'session_token': 'token',
        'refresh_token': 'refresh',
      });
      await StorageService.initialize();

      provider = AuthProvider(
        authRepository: FakeAuthRepository(
          FakeBackend(
            seedParkings: demoCity.seedParkings,
            latency: Duration.zero,
          ),
        ),
        biometricAuthenticator: biometrics,
      );
      // Restaura la sesión. Con biometría activada esto ya consume una llamada,
      // así que después reiniciamos el contador.
      await provider.initialize(biometricReason: 'motivo');
      biometrics.authenticateCalls = 0;
    });

    return provider;
  }

  Future<void> pumpGate(WidgetTester tester, AuthProvider authProvider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppLockGate(
            clock: () => now,
            child: const Scaffold(body: Text('CONTENIDO PRIVADO')),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// La app se va al segundo plano y vuelve tras [away] (según el reloj falso).
  Future<void> backgroundAndResume(WidgetTester tester, Duration away) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    now = now.add(away);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
      'con biometría activada, al volver del segundo plano tras el margen se '
      'exige la huella (no solo en arranque en frío)', (tester) async {
    final biometrics = _FakeBiometrics();
    final authProvider = await givenLoggedInSession(
      tester,
      biometrics: biometrics,
      biometricEnabled: true,
    );
    expect(authProvider.isLoggedIn, isTrue);

    await pumpGate(tester, authProvider);
    expect(find.text('CONTENIDO PRIVADO'), findsOneWidget);

    await backgroundAndResume(tester, _beyondGrace);

    // Se pidió la huella y, al superarla, se desbloquea.
    expect(biometrics.authenticateCalls, 1);
    await tester.pump();
    expect(find.text('App bloqueada'), findsNothing);
    expect(find.text('CONTENIDO PRIVADO'), findsOneWidget);
  });

  testWidgets('si la huella falla al desbloquear, la app queda BLOQUEADA',
      (tester) async {
    // Sesión abierta, pero la huella falla al intentar desbloquear.
    final biometrics = _FakeBiometrics(succeeds: false);
    final authProvider = await givenLoggedInSession(
      tester,
      biometrics: biometrics,
      // Se restaura sin biometría (para tener sesión viva)...
      biometricEnabled: false,
    );
    // ...y a partir de aquí la biometría queda activada.
    await tester.runAsync(() async {
      await StorageService.setBool(AppConstants.prefKeyBiometricEnabled, true);
    });
    expect(authProvider.isLoggedIn, isTrue);

    await pumpGate(tester, authProvider);
    await backgroundAndResume(tester, _beyondGrace);
    await tester.pump();

    expect(biometrics.authenticateCalls, 1);
    // Pantalla de bloqueo visible, con reintento y salida por contraseña.
    expect(find.text('App bloqueada'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Usar contraseña'), findsOneWidget);
  });

  testWidgets('dentro del margen de gracia NO se pide la huella',
      (tester) async {
    final biometrics = _FakeBiometrics();
    final authProvider = await givenLoggedInSession(
      tester,
      biometrics: biometrics,
      biometricEnabled: true,
    );

    await pumpGate(tester, authProvider);
    await backgroundAndResume(tester, const Duration(seconds: 2));

    expect(biometrics.authenticateCalls, 0);
    expect(find.text('CONTENIDO PRIVADO'), findsOneWidget);
  });

  testWidgets('con la biometría DESACTIVADA nunca se pide al volver',
      (tester) async {
    final biometrics = _FakeBiometrics();
    final authProvider = await givenLoggedInSession(
      tester,
      biometrics: biometrics,
      biometricEnabled: false,
    );

    await pumpGate(tester, authProvider);
    await backgroundAndResume(tester, _beyondGrace);

    expect(biometrics.authenticateCalls, 0);
    expect(find.text('CONTENIDO PRIVADO'), findsOneWidget);
  });
}
