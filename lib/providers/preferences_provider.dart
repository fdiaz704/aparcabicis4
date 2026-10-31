import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Preferencias de la app (Ajustes): idioma, tema y avisos.
///
/// Se leen de forma **síncrona** en el constructor: si se cargaran con un
/// `Future`, el primer frame saldría con el idioma y el tema equivocados y el
/// usuario vería el parpadeo.
///
/// En fase 4 estas mismas preferencias viajan al servidor con
/// `PATCH /me/preferences`.
class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider() {
    _themeMode = _readThemeMode();
    _locale = _readLocale();
    _notificationsEnabled =
        StorageService.getBool(AppConstants.prefKeyNotificationsEnabled) ?? true;
  }

  late ThemeMode _themeMode;
  late Locale? _locale;
  late bool _notificationsEnabled;

  /// Tema activo. `system` sigue al del dispositivo.
  ThemeMode get themeMode => _themeMode;

  /// Idioma elegido, o `null` si se sigue al del sistema.
  Locale? get locale => _locale;

  /// Preferencia de avisos push. De momento **solo se guarda**: los avisos de
  /// reserva y uso son locales y no la consultan. El backend la usará cuando
  /// haya push (fase 4+).
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await StorageService.setString(AppConstants.prefKeyThemeMode, mode.name);
  }

  /// [locale] `null` = seguir al idioma del sistema.
  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await StorageService.remove(AppConstants.prefKeyLocale);
    } else {
      await StorageService.setString(
        AppConstants.prefKeyLocale,
        locale.languageCode,
      );
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
    await StorageService.setBool(
      AppConstants.prefKeyNotificationsEnabled,
      enabled,
    );
  }

  static ThemeMode _readThemeMode() {
    final stored = StorageService.getString(AppConstants.prefKeyThemeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  static Locale? _readLocale() {
    final stored = StorageService.getString(AppConstants.prefKeyLocale);
    return stored == null || stored.isEmpty ? null : Locale(stored);
  }
}
