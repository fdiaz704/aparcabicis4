import '../../models/auth_session.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../auth_repository.dart';
import '../repository_exception.dart';
import 'fake_backend.dart';

/// Autenticación simulada, sin red.
///
/// Reproduce el comportamiento actual de la app (acepta cualquier email con
/// formato válido y contraseña de al menos 8 caracteres) y devuelve un par de
/// tokens ficticios, para que la capa superior ya trabaje como lo hará contra
/// la API real. La contraseña nunca se persiste (RF-1.3).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._backend);

  final FakeBackend _backend;

  static final RegExp _emailPattern =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool _isValidEmail(String email) => _emailPattern.hasMatch(email.trim());

  /// Al menos una letra y un número.
  bool _isStrongPassword(String password) =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);

  AuthSession _sessionFor(String email) {
    final user = User(email: email.trim());
    _backend.currentUser = user;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return AuthSession(
      user: user,
      accessToken: 'fake-access-$stamp',
      refreshToken: 'fake-refresh-$stamp',
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_backend.latency);

    if (!_isValidEmail(email) || password.length < AppConstants.minPasswordLength) {
      throw const RepositoryException(
        RepositoryErrorCodes.invalidCredentials,
        'Email o contraseña incorrectos.',
      );
    }
    return _sessionFor(email);
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future<void>.delayed(_backend.latency);

    if (!_isValidEmail(email)) {
      throw const RepositoryException(
        RepositoryErrorCodes.invalidEmail,
        'Email no válido.',
      );
    }
    if (password.length < AppConstants.minPasswordLength) {
      throw const RepositoryException(
        RepositoryErrorCodes.weakPassword,
        'La contraseña es demasiado corta.',
      );
    }
    if (password != confirmPassword) {
      throw const RepositoryException(
        RepositoryErrorCodes.passwordMismatch,
        'Las contraseñas no coinciden.',
      );
    }
    if (!_isStrongPassword(password)) {
      throw const RepositoryException(
        RepositoryErrorCodes.weakPassword,
        'La contraseña debe contener al menos una letra y un número.',
      );
    }
    return _sessionFor(email);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future<void>.delayed(_backend.latency);
    if (!_isValidEmail(email)) {
      throw const RepositoryException(
        RepositoryErrorCodes.invalidEmail,
        'Email no válido.',
      );
    }
    // El contrato responde 202 siempre, sin revelar si el email existe.
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(_backend.latency);
    _backend.currentUser = null;
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await Future<void>.delayed(_backend.latency);

    if (!_isValidEmail(email)) {
      throw const RepositoryException(
        RepositoryErrorCodes.invalidEmail,
        'Email no válido.',
      );
    }
    if (newPassword.length < AppConstants.minPasswordLength) {
      throw const RepositoryException(
        RepositoryErrorCodes.weakPassword,
        'La nueva contraseña es demasiado corta.',
      );
    }
    if (newPassword != confirmNewPassword) {
      throw const RepositoryException(
        RepositoryErrorCodes.passwordMismatch,
        'Las contraseñas nuevas no coinciden.',
      );
    }
    if (currentPassword == newPassword) {
      throw const RepositoryException(
        RepositoryErrorCodes.samePassword,
        'La nueva contraseña debe ser diferente a la actual.',
      );
    }
    if (!_isStrongPassword(newPassword)) {
      throw const RepositoryException(
        RepositoryErrorCodes.weakPassword,
        'La nueva contraseña debe contener al menos una letra y un número.',
      );
    }
  }

  @override
  Future<void> deleteAccount({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future<void>.delayed(_backend.latency);

    if (!_isValidEmail(email)) {
      throw const RepositoryException(
        RepositoryErrorCodes.invalidEmail,
        'Email no válido.',
      );
    }
    if (password != confirmPassword) {
      throw const RepositoryException(
        RepositoryErrorCodes.passwordMismatch,
        'Las contraseñas no coinciden.',
      );
    }
    _backend.currentUser = null;
  }
}
