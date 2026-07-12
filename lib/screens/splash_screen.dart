import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/parkings_provider.dart';
import '../providers/reservations_provider.dart';
import '../providers/session_provider.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../services/navigation_service.dart';
import '../services/version_check_service.dart';
import '../utils/platform_icons.dart';
import 'update_required_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Actualización obligatoria: mientras esté puesta, el splash no navega a
  /// ningún sitio y muestra la pantalla bloqueante (RF-A.3).
  UpdateDecision? _forcedUpdate;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // Se difiere al primer frame: _initializeApp usa las localizaciones, que no
    // están disponibles hasta que initState ha terminado.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    try {
      // Start animation
      _animationController.forward();
      
      // Comprobación de versión antes que nada (RF-A.2). Si falla, deja pasar:
      // nadie se queda fuera de la app porque el servidor no conteste (RF-A.4).
      final update = await context.read<VersionCheckService>().check();
      if (!mounted) return;
      if (update.action == UpdateAction.forced) {
        setState(() => _forcedUpdate = update);
        return; // callejón sin salida: no se sigue inicializando.
      }

      // Initialize providers
      final authProvider = context.read<AuthProvider>();
      final parkingsProvider = context.read<ParkingsProvider>();
      final reservationsProvider = context.read<ReservationsProvider>();
      final sessionProvider = context.read<SessionProvider>();

      // Con biometría habilitada, initialize() pide huella/Face ID para
      // restaurar la sesión; si falla, cae al login con contraseña (RF-1.6).
      final biometricReason = context.l10n.biometricPromptReason;

      await Future.wait([
        authProvider.initialize(biometricReason: biometricReason),
        parkingsProvider.initialize(),
        reservationsProvider.initialize(),
      ]);

      // Con sesión restaurada, el bootstrap trae perfil, parámetros del sistema
      // y la reserva en curso en una sola llamada (RF-B.1).
      if (authProvider.isLoggedIn) {
        await sessionProvider.load();
        // Permiso de avisos de reserva y uso (Android 13+ e iOS). Si se deniega,
        // la app sigue funcionando: solo no llegarán los recordatorios.
        await AparcabicisApp.notifications.requestPermissions();
      }

      // Wait minimum time for splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Versión nueva no obligatoria: se avisa, pero se puede seguir.
      if (mounted && update.action == UpdateAction.optional) {
        await _showOptionalUpdateNotice(update);
      }

      // Navigate to appropriate screen
      if (mounted) {
        if (authProvider.isLoggedIn) {
          // Si hay uso en curso, se va directamente a él (RF-B.3).
          if (reservationsProvider.hasActiveReservation) {
            NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
          } else {
            NavigationService.pushNamedAndClearStack(AppRoutes.main);
          }
        } else {
          NavigationService.pushNamedAndClearStack(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      // On error, go to login
      if (mounted) {
        NavigationService.pushNamedAndClearStack(AppRoutes.login);
      }
    }
  }

  /// Aviso descartable de versión nueva (RF-A.2): informa, pero no bloquea.
  Future<void> _showOptionalUpdateNotice(UpdateDecision update) async {
    final l10n = context.l10n;
    final version = update.latestVersion ?? '';

    final wantsUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.updateAvailableTitle),
        content: Text(l10n.updateAvailableMessage(version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.updateLater),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.updateButton),
          ),
        ],
      ),
    );

    if (wantsUpdate != true) return;

    final url = update.storeUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forced = _forcedUpdate;
    if (forced != null) {
      return UpdateRequiredScreen(
        latestVersion: forced.latestVersion ?? '',
        storeUrl: forced.storeUrl,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.loginGradient,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          PlatformIcons.bike,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // App Name
                      Text(
                        context.l10n.appName,
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.sm),
                      
                      // App Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Text(
                          context.l10n.splashDescription,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Loading Indicator
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Loading Text
                      Text(
                        context.l10n.splashInitializing,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
