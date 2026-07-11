import '../models/auth_session.dart';

/// Acceso a autenticación (specs/04-API.md, sección Auth).
///
/// Lanza [RepositoryException] con el código correspondiente si la operación
/// falla. Nunca persiste contraseñas (RF-1.3).
abstract interface class AuthRepository {
  /// `POST /auth/login`.
  Future<AuthSession> login({required String email, required String password});

  /// `POST /auth/register`.
  Future<AuthSession> register({
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// `POST /auth/forgot-password`. No revela si el email existe.
  Future<void> forgotPassword(String email);

  /// Cierra la sesión (invalida el refresh token en el backend).
  Future<void> logout();

  /// `POST /me/change-password` — RF-1.7 (fuera del UI v1, se conserva por
  /// compatibilidad con las pantallas actuales).
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  /// `DELETE /me` — RF-1.7 (fuera del UI v1, ver arriba).
  Future<void> deleteAccount({
    required String email,
    required String password,
    required String confirmPassword,
  });
}
