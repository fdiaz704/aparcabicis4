import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around the platform's secure storage:
/// Keychain on iOS and Keystore-backed encrypted storage on Android.
///
/// Use this ONLY for short-lived secrets such as the session token returned by
/// the backend. Never store passwords here — passwords must not persist on the
/// device at all.
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys
  static const String _sessionTokenKey = 'session_token';

  /// Persist the session token (e.g. a JWT) returned by the backend on login.
  static Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _sessionTokenKey, value: token);
  }

  /// Read the stored session token, or null if there is none.
  static Future<String?> getSessionToken() async {
    return _storage.read(key: _sessionTokenKey);
  }

  /// Remove the session token (on logout or account deletion).
  static Future<void> deleteSessionToken() async {
    await _storage.delete(key: _sessionTokenKey);
  }

  /// Whether a session token is currently stored.
  static Future<bool> hasSessionToken() async {
    return await getSessionToken() != null;
  }
}
