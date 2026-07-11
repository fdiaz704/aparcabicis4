import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/constants.dart';

/// Único punto de persistencia local no sensible (preferencias, favoritos,
/// historial). Los secretos (tokens) NUNCA pasan por aquí: van a
/// [SecureStorageService]. Las contraseñas no se persisten en absoluto.
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await purgeLegacySecrets();
  }

  /// Limpieza de arranque: versiones antiguas guardaban la contraseña en claro
  /// en SharedPreferences. Se elimina de cualquier instalación existente, para
  /// que no quede ni un valor residual en dispositivos ya actualizados.
  static Future<void> purgeLegacySecrets() async {
    final store = _prefs;
    if (store == null) return;
    if (store.containsKey(AppConstants.prefKeyLegacyPassword)) {
      await store.remove(AppConstants.prefKeyLegacyPassword);
      debugPrint('Purgada contraseña heredada en texto plano de SharedPreferences');
    }
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  // Bool operations
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  // Int operations
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  // List<String> operations
  static Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  // JSON operations
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // JSON List operations
  static Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    return await setString(key, jsonEncode(value));
  }

  static List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // Remove operations
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  // Clear all
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // Get all keys
  static Set<String> getKeys() {
    return prefs.getKeys();
  }
}
