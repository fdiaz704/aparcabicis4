import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize and load saved credentials
  Future<void> initialize() async {
    await _loadSavedCredentials();
  }

  // Get saved credentials for auto-fill
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getString('bikeParking_rememberMe');
      final email = prefs.getString('bikeParking_email');
      final password = prefs.getString('bikeParking_password');
      
      debugPrint('AuthProvider - getSavedCredentials:');
      debugPrint('  rememberMe: $rememberMe');
      debugPrint('  email: $email');
      debugPrint('  password: ${password != null ? '[HIDDEN]' : 'null'}');
      
      if (rememberMe == 'true') {
        return {
          'email': email,
          'password': password,
        };
      }
      return {'email': null, 'password': null};
    } catch (e) {
      debugPrint('Get saved credentials error: $e');
      return {'email': null, 'password': null};
    }
  }

  // Login method
  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      // TODO: Replace with actual authentication logic
      // For now, we'll simulate a successful login
      if (email.isNotEmpty && password.length >= 8) {
        _user = User(email: email);
        _isLoggedIn = true;
        
        debugPrint('Login successful, rememberMe: $rememberMe');
        if (rememberMe) {
          debugPrint('Saving credentials...');
          await _saveCredentials(email, password, rememberMe);
        } else {
          debugPrint('Clearing saved credentials...');
          await _clearSavedCredentials();
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
    
    // Solo limpiar el estado de login, pero mantener credenciales si "Recuérdame" estaba activo
    await _clearLoginState();
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

  Future<void> _saveCredentials(String email, String password, bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bikeParking_email', email);
      await prefs.setString('bikeParking_password', password);
      await prefs.setString('bikeParking_rememberMe', 'true');
      await prefs.setBool('bikeParking_isLoggedIn', true);
      debugPrint('Credentials saved successfully');
    } catch (e) {
      debugPrint('Save credentials error: $e');
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

  // Limpiar todas las credenciales (para cuando NO se marca "Recuérdame")
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bikeParking_email');
      await prefs.remove('bikeParking_password');
      await prefs.remove('bikeParking_rememberMe');
      await prefs.setBool('bikeParking_isLoggedIn', false);
      debugPrint('Credentials cleared successfully');
    } catch (e) {
      debugPrint('Clear credentials error: $e');
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
