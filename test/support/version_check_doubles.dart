import 'package:aparcabicis4/models/version_check.dart';
import 'package:aparcabicis4/repositories/fake/fake_backend.dart';
import 'package:aparcabicis4/repositories/fake/fake_config_repository.dart';
import 'package:aparcabicis4/services/version_check_service.dart';

/// Versión instalada fija.
///
/// En un test no hay canal de plataforma que conteste a package_info_plus: sin
/// esto el splash se queda esperando la comprobación de versión para siempre.
class FixedVersionReader implements InstalledVersionReader {
  const FixedVersionReader({this.build = 1});

  final int build;

  @override
  Future<VersionCheckRequest> read() async => VersionCheckRequest(
        platform: 'android',
        versionCode: '1.0.0',
        buildNumber: build,
      );
}

/// Comprobación de versión que siempre dice "estás al día": la app arranca sin
/// pantallas de actualización de por medio.
VersionCheckService upToDateVersionCheck(FakeBackend backend) =>
    VersionCheckService(
      configRepository: FakeConfigRepository(backend),
      reader: const FixedVersionReader(),
    );
