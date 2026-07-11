import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Autenticación biométrica (RF-1.6).
///
/// Se expone tras una interfaz para poder sustituirla en tests: la biometría
/// no es ejercitable en un emulador sin huella registrada, así que los tests
/// verifican el **fallback a contraseña** con una implementación falsa.
abstract interface class BiometricAuthenticator {
  /// El dispositivo soporta biometría y tiene alguna registrada.
  Future<bool> isAvailable();

  /// Solicita la verificación biométrica. Devuelve true si el usuario se
  /// identifica correctamente.
  Future<bool> authenticate(String reason);
}

/// Implementación real sobre `local_auth`.
///
/// Requisitos nativos: `USE_BIOMETRIC` en AndroidManifest y `MainActivity`
/// extendiendo `FlutterFragmentActivity`; `NSFaceIDUsageDescription` en
/// Info.plist.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator([LocalAuthentication? localAuth])
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('Biometría no disponible: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // Sin biometría registrada, bloqueada tras varios fallos, cancelada…
      // En todos los casos la app debe caer al login con contraseña.
      debugPrint('Fallo de autenticación biométrica: $e');
      return false;
    }
  }
}
