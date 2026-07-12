import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aparcabicis4/config/cities/demo.dart';
import 'package:aparcabicis4/config/city_config.dart';
import 'package:aparcabicis4/l10n/app_localizations.dart';
import 'package:aparcabicis4/providers/auth_provider.dart';
import 'package:aparcabicis4/providers/preferences_provider.dart';
import 'package:aparcabicis4/repositories/fake/fake_auth_repository.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/screens/main/settings_screen.dart';
import 'package:aparcabicis4/services/storage_service.dart';

/// Réplica mínima de lo que hace `main.dart`: el idioma y el tema salen del
/// provider, así que cambiarlos reconstruye la app. Sin esto no se podría
/// comprobar el cambio "en caliente".
class _TestApp extends StatelessWidget {
  const _TestApp({required this.city});

  final CityConfig city;

  @override
  Widget build(BuildContext context) {
    final backend = FakeBackend(seedParkings: const [], latency: Duration.zero);
    return MultiProvider(
      providers: [
        Provider<CityConfig>.value(value: city),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: FakeAuthRepository(backend)),
        ),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, preferences, _) => MaterialApp(
          locale: preferences.locale,
          themeMode: preferences.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: city.supportedLocales,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
  }
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Aparcabicis',
      packageName: 'com.r3recymed.aparcabicis.demo',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
    await StorageService.initialize();
  });

  group('PreferencesProvider (RF-6)', () {
    test('por defecto: idioma y tema del sistema, avisos activados', () {
      final preferences = PreferencesProvider();

      expect(preferences.locale, isNull);
      expect(preferences.themeMode, ThemeMode.system);
      expect(preferences.notificationsEnabled, isTrue);
    });

    test('las preferencias sobreviven a un reinicio de la app', () async {
      final preferences = PreferencesProvider();
      await preferences.setLocale(const Locale('ca'));
      await preferences.setThemeMode(ThemeMode.dark);
      await preferences.setNotificationsEnabled(false);

      // Otra instancia = otro arranque: se leen de disco, no de memoria.
      final reloaded = PreferencesProvider();

      expect(reloaded.locale?.languageCode, 'ca');
      expect(reloaded.themeMode, ThemeMode.dark);
      expect(reloaded.notificationsEnabled, isFalse);
    });

    test('volver a "idioma del sistema" borra la preferencia guardada',
        () async {
      final preferences = PreferencesProvider();
      await preferences.setLocale(const Locale('ca'));
      await preferences.setLocale(null);

      expect(PreferencesProvider().locale, isNull);
    });
  });

  group('pantalla de Ajustes (RF-6)', () {
    testWidgets('ya no hay tarjeta "Cuenta": esas acciones viven en Perfil',
        (tester) async {
      await tester.pumpWidget(const _TestApp(city: demoCity));
      await tester.pumpAndSettle();

      expect(find.text('Cuenta'), findsNothing);
      expect(find.text('Cambiar contraseña'), findsNothing);
      expect(find.text('Eliminar cuenta'), findsNothing);
    });

    testWidgets('"Acerca de" muestra versión instalada, ciudad y sistema',
        (tester) async {
      await tester.pumpWidget(const _TestApp(city: demoCity));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Acerca de'), 200);
      await tester.pumpAndSettle();

      expect(find.text('1.2.3 (42)'), findsOneWidget);
      expect(find.text(demoCity.name), findsOneWidget);
    });

    testWidgets('elegir Valencià cambia el idioma en caliente y lo persiste',
        (tester) async {
      await tester.pumpWidget(const _TestApp(city: demoCity));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Idioma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valencià').last);
      await tester.pumpAndSettle();

      // La pantalla se ha redibujado en valenciano, sin reiniciar la app.
      expect(find.text('Configuración de la aplicación'), findsNothing);
      expect(find.text("Configuració de l'aplicació"), findsOneWidget);

      // Y queda guardado para el siguiente arranque.
      expect(PreferencesProvider().locale?.languageCode, 'ca');
    });

    testWidgets('elegir tema oscuro lo aplica a la app', (tester) async {
      await tester.pumpWidget(const _TestApp(city: demoCity));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tema'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oscuro').last);
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(PreferencesProvider().themeMode, ThemeMode.dark);
    });
  });
}
