import '../../models/bootstrap_data.dart';
import '../../models/version_check.dart';
import '../config_repository.dart';
import '../repository_exception.dart';
import 'fake_backend.dart';

/// Bootstrap y comprobación de versión simulados.
///
/// Ambos métodos construyen el **JSON crudo tal y como lo devuelve la API real**
/// (specs/04-API.md) y lo deserializan con el mismo parser que usará
/// `ApiConfigRepository` en la fase 4. Así el fake no puede divergir del
/// contrato: si el contrato cambia, este fake deja de compilar/parsear.
class FakeConfigRepository implements ConfigRepository {
  FakeConfigRepository(
    this._backend, {
    this.latestVersion = '1.0.0',
    this.latestBuild = 1,
    this.forceUpdate = false,
    this.updateUrl = 'https://play.google.com/store/apps/details?id=com.r3recymed.aparcabicis',
    this.clientKnown = true,
  });

  final FakeBackend _backend;

  /// Valores que devuelve `POST /check_version`. Configurables para poder
  /// probar la actualización obligatoria y el aviso descartable (RF-A).
  final String latestVersion;
  final int latestBuild;
  final bool forceUpdate;
  final String updateUrl;
  final bool clientKnown;

  @override
  Future<BootstrapData> getBootstrap() async {
    await _backend.load();
    await Future<void>.delayed(_backend.latency);

    final user = _backend.currentUser;
    if (user == null) {
      throw const RepositoryException(
        RepositoryErrorCodes.unauthenticated,
        'No hay sesión iniciada.',
      );
    }

    final current = await _backend.fetchCurrentReservation();

    // Forma exacta de la respuesta de GET /bootstrap (specs/04-API.md).
    final json = <String, dynamic>{
      'user': user.toJson(),
      'params': _backend.params.toJson(),
      'stats': _backend.stats.toJson(),
      'currentReservation': current?.toJson(),
    };
    return BootstrapData.fromJson(json);
  }

  @override
  Future<VersionCheckResult> checkVersion(VersionCheckRequest request) async {
    await Future<void>.delayed(_backend.latency);

    // Forma exacta de la respuesta de POST /check_version (snake_case).
    final json = <String, dynamic>{
      'latest_version': latestVersion,
      'latest_build': latestBuild,
      'force_update': forceUpdate,
      'url': updateUrl,
      'client_known': clientKnown,
    };
    return VersionCheckResult.fromJson(json);
  }
}
