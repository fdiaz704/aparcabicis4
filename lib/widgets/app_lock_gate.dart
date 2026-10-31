import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';


/// Bloqueo biométrico de la app (RF-1.6).
///
/// Envuelve toda la app. Con biometría activada y sesión iniciada, al volver
/// del segundo plano tras más de [AppConstants.biometricLockGraceSeconds]
/// **se exige la huella/Face ID** antes de dejar ver nada. Así la biometría no
/// se pide solo en el arranque en frío, sino **siempre** que se vuelve a la app.
///
/// El margen de gracia evita pedirla en cambios de foco fugaces (mirar una
/// notificación, el selector de apps…).
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, this.grace, this.clock, super.key});

  final Widget child;

  /// Reloj usado para medir el tiempo en segundo plano. Inyectable en tests
  /// (en un widget test el tiempo no avanza solo).
  final DateTime Function()? clock;

  /// Margen de inactividad tras el cual se vuelve a exigir la biometría.
  /// Por defecto, [AppConstants.biometricLockGraceSeconds]. Inyectable para
  /// no tener que esperar en tiempo real en los tests.
  final Duration? grace;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;
  bool _authenticating = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= _now();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  DateTime _now() => (widget.clock ?? DateTime.now)();

  void _onResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null || _locked) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn || !authProvider.isBiometricEnabled) return;

    // Solo si estuvo fuera más del margen de gracia.
    final grace = widget.grace ??
        const Duration(seconds: AppConstants.biometricLockGraceSeconds);
    final away = _now().difference(backgroundedAt);
    if (away < grace) return;

    setState(() => _locked = true);
    _promptUnlock();
  }

  Future<void> _promptUnlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    final authProvider = context.read<AuthProvider>();
    final unlocked =
        await authProvider.unlockWithBiometrics(context.l10n.biometricPromptReason);

    if (!mounted) return;
    setState(() {
      _authenticating = false;
      if (unlocked) _locked = false;
    });
  }

  /// Fallback: salir del bloqueo cerrando sesión para entrar con contraseña.
  Future<void> _usePassword() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;
    setState(() => _locked = false);
    NavigationService.pushNamedAndClearStack(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked) _buildLockOverlay(context),
      ],
    );
  }

  Widget _buildLockOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.lockTitle,
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.lockMessage,
                    style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_authenticating)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton.icon(
                      onPressed: _promptUnlock,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(context.l10n.lockRetry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _authenticating ? null : _usePassword,
                    child: Text(context.l10n.lockUsePassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
