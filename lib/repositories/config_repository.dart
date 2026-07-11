import '../models/bootstrap_data.dart';
import '../models/version_check.dart';

/// Configuración y arranque de sesión (specs/04-API.md).
abstract interface class ConfigRepository {
  /// `GET /bootstrap` (RF-B.1): perfil + parámetros del sistema + estadísticas
  /// + reserva en curso (o null), en una sola llamada.
  Future<BootstrapData> getBootstrap();

  /// `POST /check_version` (RF-A.2): comprobación de versión contra el backend.
  Future<VersionCheckResult> checkVersion(VersionCheckRequest request);
}
