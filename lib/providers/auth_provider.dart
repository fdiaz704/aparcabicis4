import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize: purge any legacy plaintext password, then load saved state
  Future<void> initialize() async {
    await _migrateLegacyCredentials();
    await _loadSavedCredentials();
  }

  // One-time cleanup: older versions stored the password in plain text in
  // SharedPreferences. Remove it from any existing install. Passwords must
  // never persist on the device.
  Future<void> _migrateLegacyCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('bikeParking_password')) {
        await prefs.remove('bikeParking_password');
        debugPrint('Removed legacy plaintext password from storage');
      }
    } catch (e) {
      debugPrint('Legacy credential migration error: $e');
    }
  }

  // Get the remembered email for auto-fill (never the password).
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getString('bikeParking_rememberMe');
      if (rememberMe == 'true') {
        return prefs.getString('bikeParking_email');
      }
      return null;
    } catch (e) {
      debugPrint('Get saved email error: $e');
      return null;
    }
  }

  // Login method
  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      // TODO: Replace with a real backend call. On success the backend should
      // return a session token; persist ONLY the token (never the password):
      //   await SecureStorageService.saveSessionToken(response.token);
      // For now, we simulate a successful login.
      if (_isValidEmail(email.trim()) && password.length >= 8) {
        _user = User(email: email);
        _isLoggedIn = true;

        // "Recuérdame" only remembers the email to pre-fill the form next time.
        // The password is never persisted on the device.
        if (rememberMe) {
          await _saveRememberedEmail(email);
        } else {
          await _clearRememberedEmail();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;

    // Clear the login state but keep the remembered email if "Recuérdame" was on.
    await _clearLoginState();
    // Drop any session token from secure storage (no-op if none stored yet).
    await SecureStorageService.deleteSessionToken();
    notifyListeners();
  }

  // Create user method
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validations
      if (email.trim().isEmpty) {
        return {'success': false, 'message': 'El email es requerido'};
      }
      
      if (!_isValidEmail(email.trim())) {
        return {'success': false, 'message': 'Por favor ingresa un email válido'};
      }
      
      if (password.isEmpty) {
        return {'success': false, 'message': 'La contraseña es requerida'};
      }
      
      if (password.length < 8) {
        return {'success': false, 'message': 'La contraseña debe tener al menos 8 caracteres'};
      }
      
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Las contraseñas no coinciden'};
      }
      
      // Check password strength
      if (!_isStrongPassword(password)) {
        return {'success': false, 'message': 'La contraseña debe contener al menos una letra y un número'};
      }
      
      // TODO: Replace with actual user creation logic
      // Simulate checking if email already exists
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For now, we'll simulate a successful creation
      return {'success': true, 'message': 'Usuario creado exitosamente'};
    } catch (e) {
      debugPrint('Create user error: $e');
      return {'success': false, 'message': 'Error interno del servidor'};
    }
  }

  // Change password method
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      // Validations
      if (email.trim().isEmpty) {
        return {'success': false, 'message': 'El email es requerido'};
      }
      
      if (!_isValidEmail(email.trim())) {
        return {'success': false, 'message': 'Por favor ingresa un email válido'};
      }
      
      if (currentPassword.isEmpty) {
        return {'success': false, 'message': 'La contraseña actual es requerida'};
      }
      
      if (newPassword.isEmpty) {
        return {'success': false, 'message': 'La nueva contraseña es requerida'};
      }
      
      if (newPassword.length < 8) {
        return {'success': false, 'message': 'La nueva contraseña debe tener al menos 8 caracteres'};
      }
      
      if (newPassword != confirmNewPassword) {
        return {'success': false, 'message': 'Las contraseñas nuevas no coinciden'};
      }
      
      if (currentPassword == newPassword) {
        return {'success': false, 'message': 'La nueva contraseña debe ser diferente a la actual'};
      }
      
      if (!_isStrongPassword(newPassword)) {
        return {'success': false, 'message': 'La nueva contraseña debe contener al menos una letra y un número'};
      }
      
      // TODO: Replace with actual password change logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {'success': true, 'message': 'Contraseña cambiada exitosamente'};
    } catch (e) {
      debugPrint('Change password error: $e');
      return {'success': false, 'message': 'Error interno del servidor'};
    }
  }

  // Delete user method
  Future<Map<String, dynamic>> deleteUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String confirmationText,
  }) async {
    try {
      // Validations
      if (email.trim().isEmpty) {
        return {'success': false, 'message': 'El email es requerido'};
      }
      
      if (!_isValidEmail(email.trim())) {
        return {'success': false, 'message': 'Por favor ingresa un email válido'};
      }
      
      if (password.isEmpty) {
        return {'success': false, 'message': 'La contraseña es requerida'};
      }
      
      if (confirmPassword.isEmpty) {
        return {'success': false, 'message': 'La confirmación de contraseña es requerida'};
      }
      
      if (password != confirmPassword) {
        return {'success': false, 'message': 'Las contraseñas no coinciden'};
      }
      
      if (confirmationText.trim().isEmpty) {
        return {'success': false, 'message': 'Debes escribir ELIMINAR para confirmar'};
      }
      
      if (confirmationText.toLowerCase() != 'eliminar') {
        return {'success': false, 'message': 'Debes escribir exactamente "ELIMINAR" para confirmar'};
      }
      
      // TODO: Replace with actual user deletion logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {'success': true, 'message': 'Cuenta eliminada exitosamente'};
    } catch (e) {
      debugPrint('Delete user error: $e');
      return {'success': false, 'message': 'Error interno del servidor'};
    }
  }

  // Send password reset email
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      if (email.trim().isEmpty) {
        return {'success': false, 'message': 'El email es requerido'};
      }
      
      if (!_isValidEmail(email.trim())) {
        return {'success': false, 'message': 'Por favor ingresa un email válido'};
      }
      
      // TODO: Replace with actual password reset logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {'success': true, 'message': 'Email de recuperación enviado exitosamente'};
    } catch (e) {
      debugPrint('Send password reset error: $e');
      return {'success': false, 'message': 'Error interno del servidor'};
    }
  }

  // Private methods
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getString('bikeParking_rememberMe');
      
      // Solo verificar si el usuario ya estaba logueado previamente
      // El "Recuérdame" solo debe pre-llenar campos, no loguear automáticamente
      if (rememberMe == 'true') {
        final email = prefs.getString('bikeParking_email');
        final isLoggedIn = prefs.getBool('bikeParking_isLoggedIn') ?? false;
        
        if (email != null && email.isNotEmpty && isLoggedIn) {
          _user = User(email: email);
          _isLoggedIn = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Load credentials error: $e');
    }
  }

  // Persist only the email (and session flags) for "Recuérdame".
  // The password is intentionally never stored.
  Future<void> _saveRememberedEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bikeParking_email', email);
      await prefs.setString('bikeParking_rememberMe', 'true');
      await prefs.setBool('bikeParking_isLoggedIn', true);
    } catch (e) {
      debugPrint('Save remembered email error: $e');
    }
  }

  // Limpiar solo el estado de login (para logout)
  Future<void> _clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('bikeParking_isLoggedIn', false);
      debugPrint('Login state cleared successfully');
    } catch (e) {
      debugPrint('Clear login state error: $e');
    }
  }

  // Clear the remembered email (for when "Recuérdame" is NOT checked).
  Future<void> _clearRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bikeParking_email');
      await prefs.remove('bikeParking_rememberMe');
      await prefs.remove('bikeParking_password'); // legacy cleanup
      await prefs.setBool('bikeParking_isLoggedIn', false);
    } catch (e) {
      debugPrint('Clear remembered email error: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // At least one letter and one number
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }
}
