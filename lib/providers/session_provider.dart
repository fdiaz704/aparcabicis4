import 'package:flutter/foundation.dart';

import '../models/app_params.dart';
import '../models/bootstrap_data.dart';
import '../models/reservation.dart';
import '../models/user.dart';
import '../repositories/config_repository.dart';
import '../repositories/repository_exception.dart';

/// Estado de sesión derivado del bootstrap (RF-B).
///
/// Tras el login (o la restauración de sesión) una sola llamada a
/// `GET /bootstrap` trae perfil, parámetros del sistema, estadísticas y la
/// reserva en curso. Los **parámetros de tiempo salen de aquí**: la app no
/// hardcodea ventanas ni avisos (RF-B.2).
class SessionProvider with ChangeNotifier {
  SessionProvider({required ConfigRepository configRepository})
      : _configRepository = configRepository;

  final ConfigRepository _configRepository;

  BootstrapData? _bootstrap;
  bool _isLoading = false;
  String? _errorCode;

  BootstrapData? get bootstrap => _bootstrap;
  bool get isLoading => _isLoading;
  String? get errorCode => _errorCode;

  User? get user => _bootstrap?.user;
  UserStats? get stats => _bootstrap?.stats;

  /// Parámetros del sistema. Si aún no hay bootstrap, se usan los valores por
  /// defecto de la spec para no dejar la UI sin tiempos.
  AppParams get params => _bootstrap?.params ?? AppParams.defaults;

  /// Reserva en curso servida por el bootstrap (o null).
  Reservation? get currentReservation => _bootstrap?.currentReservation;

  /// Si hay uso en curso, la app navega al uso activo y bloquea nuevas
  /// reservas (RF-B.3).
  bool get hasOngoingReservation => _bootstrap?.hasOngoingReservation ?? false;

  /// Carga el bootstrap. Devuelve null si falla (p. ej. sin sesión).
  Future<BootstrapData?> load() async {
    _isLoading = true;
    _errorCode = null;
    notifyListeners();

    try {
      final data = await _configRepository.getBootstrap();
      _bootstrap = data;
      return data;
    } on RepositoryException catch (e) {
      _errorCode = e.code;
      debugPrint('Bootstrap error: $e');
      return null;
    } catch (e) {
      _errorCode = 'UNKNOWN';
      debugPrint('Bootstrap error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia la sesión (logout).
  void clear() {
    _bootstrap = null;
    _errorCode = null;
    notifyListeners();
  }
}
