import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro de la plataforma: Keychain en iOS y almacenamiento
/// cifrado respaldado por Keystore en Android.
///
/// Aquí van SOLO los secretos de sesión (tokens JWT). La **contraseña nunca se
/// persiste** en el dispositivo, ni aquí ni en SharedPreferences (RF-1.3).
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'session_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Guarda el par de tokens devuelto por la API en el login.
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Guarda solo el access token (renovación silenciosa, RF-1.4).
  static Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getSessionToken() => _storage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Elimina la sesión completa (logout, borrado de cuenta o "Recuérdame" off).
  static Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Alias histórico de [clearSession].
  static Future<void> deleteSessionToken() => clearSession();

  static Future<bool> hasSessionToken() async =>
      await getSessionToken() != null;
}
