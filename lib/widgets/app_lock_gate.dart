import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';


/// Bloqueo biométrico de la app (RF-1.6).
///
/// Envuelve toda la app. Con biometría activada y sesión iniciada, al volver
/// del segundo plano **se exige la huella/Face ID** antes de dejar ver nada.
/// Sin margen de gracia (decisión de producto 2026-10-31): cualquier paso por
/// segundo plano exige la huella al volver;
/// [AppConstants.biometricLockGraceSeconds] vale 0 y solo los tests inyectan
/// otros márgenes vía [AppLockGate.grace].
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, this.grace, this.clock, super.key});

  final Widget child;

  /// Reloj usado para medir el tiempo en segundo plano. Inyectable en tests
  /// (en un widget test el tiempo no avanza solo).
  final DateTime Function()? clock;

  /// Margen de inactividad tras el cual se vuelve a exigir la biometría.
  /// Por defecto, [AppConstants.biometricLockGraceSeconds] (= 0: huella
  /// SIEMPRE al volver). Inyectable solo para los tests.
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
        // El propio diálogo biométrico del sistema pausa la actividad en
        // Android: sin esta guarda, cada desbloqueo volvería a bloquear en
        // bucle al no existir margen de gracia.
        if (!_authenticating) _backgroundedAt ??= _now();
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

    // El margen por defecto sale de la constante de producto (hoy 0 = huella
    // SIEMPRE al volver). El lint ve redundante `seconds: 0`, pero se conserva
    // la referencia a la constante como única fuente de verdad.
    final grace = widget.grace ??
        // ignore: avoid_redundant_argument_values
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
