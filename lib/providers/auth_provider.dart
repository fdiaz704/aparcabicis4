import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository_exception.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Estado de autenticación.
///
/// No conoce la fuente de datos: todo pasa por [AuthRepository] (fake en
/// desarrollo, API en producción). La contraseña nunca se persiste (RF-1.3).
class AuthProvider with ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    BiometricAuthenticator? biometricAuthenticator,
  })  : _authRepository = authRepository,
        _biometrics = biometricAuthenticator ?? LocalAuthBiometricAuthenticator();

  final AuthRepository _authRepository;
  final BiometricAuthenticator _biometrics;

  User? _user;
  bool _isLoggedIn = false;
  bool _biometricFallbackRequired = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  /// True si había sesión guardada pero la biometría falló o no está
  /// disponible: la UI debe pedir la contraseña (fallback, RF-1.6).
  bool get biometricFallbackRequired => _biometricFallbackRequired;

  /// Si el usuario habilitó la restauración de sesión con biometría.
  bool get isBiometricEnabled =>
      StorageService.getBool(AppConstants.prefKeyBiometricEnabled) ?? false;

  /// El dispositivo admite biometría (hay huella/Face ID registrado).
  Future<bool> isBiometricAvailable() => _biometrics.isAvailable();

  /// Alta de biometría (se ofrece al activar "Recuérdame").
  ///
  /// Pide una verificación de prueba: si el usuario no la supera, no se activa.
  Future<bool> enableBiometrics(String reason) async {
    if (!await _biometrics.isAvailable()) return false;
    if (!await _biometrics.authenticate(reason)) return false;

    await StorageService.setBool(AppConstants.prefKeyBiometricEnabled, true);
    notifyListeners();
    return true;
  }

  Future<void> disableBiometrics() async {
    await StorageService.setBool(AppConstants.prefKeyBiometricEnabled, false);
    notifyListeners();
  }

  /// Restaura la sesión si procede.
  ///
  /// "Recuérdame" significa **mantener la sesión** entre arranques: si está
  /// activo y hay tokens en almacenamiento seguro, se restaura al usuario. Si
  /// NO está activo, se destruye cualquier sesión persistida.
  ///
  /// Con biometría habilitada (RF-1.6), la restauración exige huella/Face ID.
  /// Si la biometría falla o el dispositivo no la soporta, NO se restaura la
  /// sesión y la UI pide la contraseña ([biometricFallbackRequired]).
  Future<void> initialize({String biometricReason = ''}) async {
    // La contraseña heredada en claro ya se purga en StorageService.initialize().
    _biometricFallbackRequired = false;

    final rememberMe =
        StorageService.getString(AppConstants.prefKeyRememberMe) == 'true';

    if (!rememberMe) {
      await SecureStorageService.clearSession();
      await _clearRememberedEmail();
      return;
    }

    final hasToken = await SecureStorageService.hasSessionToken();
    final email = StorageService.getString(AppConstants.prefKeyEmail);
    if (!hasToken || email == null || email.isEmpty) return;

    if (isBiometricEnabled) {
      final verified = await _biometrics.isAvailable() &&
          await _biometrics.authenticate(biometricReason);
      if (!verified) {
        // Fallback: la sesión no se restaura; el usuario entra con contraseña.
        _biometricFallbackRequired = true;
        notifyListeners();
        return;
      }
    }

    _user = User(email: email);
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Email recordado para prellenar el formulario (nunca la contraseña).
  Future<String?> getSavedEmail() async {
    if (StorageService.getString(AppConstants.prefKeyRememberMe) != 'true') {
      return null;
    }
    return StorageService.getString(AppConstants.prefKeyEmail);
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = session.user;
      _isLoggedIn = true;

      // Solo se persisten los tokens, y en almacenamiento seguro. La contraseña
      // no se guarda en ningún sitio (RF-1.3).
      await SecureStorageService.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      if (rememberMe) {
        await _saveRememberedEmail(session.user.email);
      } else {
        await _clearRememberedEmail();
      }

      notifyListeners();
      return true;
    } on RepositoryException catch (e) {
      debugPrint('Login error: $e');
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _user = null;
    _isLoggedIn = false;

    // Se destruyen los tokens; el email recordado se conserva solo para
    // prellenar el formulario si "Recuérdame" seguía activo.
    await SecureStorageService.clearSession();
    notifyListeners();
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _run(() async {
      await _authRepository.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return 'Usuario creado exitosamente';
    });
  }

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _run(() async {
      await _authRepository.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return 'Contraseña cambiada exitosamente';
    });
  }

  Future<Map<String, dynamic>> deleteUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String confirmationText,
  }) {
    return _run(() async {
      if (confirmationText.trim().toUpperCase() !=
          AppConstants.deleteConfirmationText) {
        throw const RepositoryException(
          RepositoryErrorCodes.passwordMismatch,
          'Debes escribir exactamente "ELIMINAR" para confirmar',
        );
      }
      await _authRepository.deleteAccount(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return 'Cuenta eliminada exitosamente';
    });
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) {
    return _run(() async {
      await _authRepository.forgotPassword(email);
      return 'Email de recuperación enviado exitosamente';
    });
  }

  /// Ejecuta una operación del repositorio y la traduce al contrato
  /// `{success, message, code}` que consumen las pantallas.
  Future<Map<String, dynamic>> _run(Future<String> Function() action) async {
    try {
      final message = await action();
      return {'success': true, 'message': message};
    } on RepositoryException catch (e) {
      return {'success': false, 'message': e.message, 'code': e.code};
    } catch (e) {
      debugPrint('Auth operation error: $e');
      return {'success': false, 'message': 'Error interno del servidor'};
    }
  }

  Future<void> _saveRememberedEmail(String email) async {
    try {
      await StorageService.setString(AppConstants.prefKeyEmail, email);
      await StorageService.setString(AppConstants.prefKeyRememberMe, 'true');
    } catch (e) {
      debugPrint('Save remembered email error: $e');
    }
  }

  Future<void> _clearRememberedEmail() async {
    try {
      await StorageService.remove(AppConstants.prefKeyEmail);
      await StorageService.remove(AppConstants.prefKeyRememberMe);
    } catch (e) {
      debugPrint('Clear remembered email error: $e');
    }
  }
}
