import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/version_check.dart';
import '../repositories/config_repository.dart';

/// Lee la versión del binario instalado (RF-A.1).
///
/// Es una interfaz porque `package_info_plus` habla con el canal de plataforma
/// y en un test no hay plataforma que responda.
abstract interface class InstalledVersionReader {
  Future<VersionCheckRequest> read();
}

/// Implementación real: package_info_plus + la plataforma en curso.
class PackageInfoVersionReader implements InstalledVersionReader {
  const PackageInfoVersionReader();

  @override
  Future<VersionCheckRequest> read() async {
    final info = await PackageInfo.fromPlatform();
    return VersionCheckRequest(
      platform: Platform.isIOS ? 'ios' : 'android',
      versionCode: info.version,
      // buildNumber viene como texto ("12"); si no es un entero, se manda 0 y
      // el backend lo tratará como cliente desconocido.
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }
}

/// Qué debe hacer la app tras comprobar la versión.
enum UpdateAction {
  /// Al día, o la comprobación falló: se sigue adelante (RF-A.4).
  none,

  /// Hay versión nueva pero no es obligatoria: aviso descartable.
  optional,

  /// Actualización obligatoria: pantalla bloqueante (RF-A.3).
  forced,
}

/// Resultado de la comprobación, ya interpretado.
class UpdateDecision {
  const UpdateDecision(this.action, {this.latestVersion, this.storeUrl});

  final UpdateAction action;
  final String? latestVersion;

  /// Enlace de la tienda que abre el botón "Actualizar".
  final String? storeUrl;

  static const UpdateDecision none = UpdateDecision(UpdateAction.none);
}

/// Comprobación de versión en el arranque (RF-A.2).
///
/// Regla de oro (RF-A.4): **si la comprobación falla, se deja pasar**. No se
/// puede dejar a un usuario fuera de la app porque el servidor no conteste.
class VersionCheckService {
  VersionCheckService({
    required ConfigRepository configRepository,
    InstalledVersionReader reader = const PackageInfoVersionReader(),
    this.timeout = const Duration(seconds: 8),
  })  : _config = configRepository,
        _reader = reader;

  final ConfigRepository _config;
  final InstalledVersionReader _reader;

  /// Tope de espera. Sin él, un servidor que acepta la conexión y no responde
  /// dejaría al usuario mirando el splash indefinidamente.
  final Duration timeout;

  Future<UpdateDecision> check() async {
    final VersionCheckRequest installed;
    final VersionCheckResult latest;
    try {
      installed = await _reader.read().timeout(timeout);
      latest = await _config.checkVersion(installed).timeout(timeout);
    } catch (e) {
      // Sin red, servidor caído, canal de plataforma mudo… se sigue y se
      // reintentará en el siguiente arranque.
      debugPrint('No se pudo comprobar la versión: $e');
      return UpdateDecision.none;
    }

    if (latest.forceUpdate) {
      return UpdateDecision(
        UpdateAction.forced,
        latestVersion: latest.latestVersion,
        storeUrl: latest.url,
      );
    }

    if (latest.isOutdated(installed.buildNumber)) {
      return UpdateDecision(
        UpdateAction.optional,
        latestVersion: latest.latestVersion,
        storeUrl: latest.url,
      );
    }

    return UpdateDecision.none;
  }
}
