import 'user.dart';

/// Sesión devuelta por `POST /auth/login` y `POST /auth/register`
/// (specs/04-API.md): perfil + par de tokens JWT.
///
/// Los tokens se guardan SOLO en almacenamiento seguro (RF-1.3). La contraseña
/// nunca se persiste.
class AuthSession {
  final User user;
  final String accessToken;
  final String refreshToken;

  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
