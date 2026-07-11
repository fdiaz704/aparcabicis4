/// Petición de `POST /check_version` (specs/04-API.md).
///
/// Los nombres JSON son **snake_case** porque así los define el endpoint real
/// ya existente en el hosting.
class VersionCheckRequest {
  /// `android` | `ios`.
  final String platform;

  /// Versión legible del binario instalado, p. ej. `1.0.0`.
  final String versionCode;

  /// Número de build incremental del binario instalado.
  final int buildNumber;

  const VersionCheckRequest({
    required this.platform,
    required this.versionCode,
    required this.buildNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'version_code': versionCode,
      'build_number': buildNumber,
    };
  }
}

/// Respuesta de `POST /check_version` (specs/04-API.md).
class VersionCheckResult {
  /// Última versión publicada, p. ej. `1.2.0`.
  final String latestVersion;

  /// Último build publicado.
  final int latestBuild;

  /// Si true ⇒ actualización obligatoria (pantalla bloqueante, RF-A.3).
  final bool forceUpdate;

  /// Enlace de la tienda para actualizar.
  final String url;

  /// Si false, el backend no reconoce esa combinación plataforma/versión.
  final bool clientKnown;

  const VersionCheckResult({
    required this.latestVersion,
    required this.latestBuild,
    required this.forceUpdate,
    required this.url,
    required this.clientKnown,
  });

  /// Hay una versión más reciente que la instalada (aviso descartable si no
  /// se fuerza la actualización).
  bool isOutdated(int installedBuild) => latestBuild > installedBuild;

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'latest_build': latestBuild,
      'force_update': forceUpdate,
      'url': url,
      'client_known': clientKnown,
    };
  }

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      latestVersion: json['latest_version'] as String,
      latestBuild: json['latest_build'] as int,
      forceUpdate: json['force_update'] as bool,
      url: json['url'] as String,
      clientKnown: json['client_known'] as bool,
    );
  }
}
