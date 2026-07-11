import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository_exception.dart';
import '../services/secure_storage_service.dart';
import '../utils/constants.dart';

/// Estado de autenticación.
///
/// No conoce la fuente de datos: todo pasa por [AuthRepository] (fake en
/// desarrollo, API en producción). La contraseña nunca se persiste (RF-1.3).
class AuthProvider with ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  /// Purga credenciales heredadas y restaura el estado de sesión guardado.
  Future<void> initialize() async {
    await _migrateLegacyCredentials();
    await _loadSavedSession();
  }

  /// Limpieza única: versiones antiguas guardaban la contraseña en claro en
  /// SharedPreferences. Se elimina de cualquier instalación existente.
  Future<void> _migrateLegacyCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(AppConstants.prefKeyLegacyPassword)) {
        await prefs.remove(AppConstants.prefKeyLegacyPassword);
        debugPrint('Eliminada contraseña heredada en texto plano');
      }
    } catch (e) {
      debugPrint('Legacy credential migration error: $e');
    }
  }

  /// Email recordado para prellenar el formulario (nunca la contraseña).
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(AppConstants.prefKeyRememberMe) == 'true') {
        return prefs.getString(AppConstants.prefKeyEmail);
      }
      return null;
    } catch (e) {
      debugPrint('Get saved email error: $e');
      return null;
    }
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(AppConstants.prefKeyRememberMe) != 'true') return;

      final email = prefs.getString(AppConstants.prefKeyEmail);
      final wasLoggedIn = prefs.getBool('bikeParking_isLoggedIn') ?? false;
      if (email != null && email.isNotEmpty && wasLoggedIn) {
        _user = User(email: email);
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load session error: $e');
    }
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = session.user;
      _isLoggedIn = true;

      // Solo se persisten los tokens (nunca la contraseña).
      await SecureStorageService.saveSessionToken(session.accessToken);

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

    await _clearLoginState();
    await SecureStorageService.deleteSessionToken();
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyEmail, email);
      await prefs.setString(AppConstants.prefKeyRememberMe, 'true');
      await prefs.setBool('bikeParking_isLoggedIn', true);
    } catch (e) {
      debugPrint('Save remembered email error: $e');
    }
  }

  Future<void> _clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('bikeParking_isLoggedIn', false);
    } catch (e) {
      debugPrint('Clear login state error: $e');
    }
  }

  Future<void> _clearRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyEmail);
      await prefs.remove(AppConstants.prefKeyRememberMe);
      await prefs.setBool('bikeParking_isLoggedIn', false);
    } catch (e) {
      debugPrint('Clear remembered email error: $e');
    }
  }
}
