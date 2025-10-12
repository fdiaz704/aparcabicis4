import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/stations_provider.dart';
import '../providers/reservations_provider.dart';
import '../utils/constants.dart';
import '../services/navigation_service.dart';

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
    
    // Start initialization
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Start animation
      _animationController.forward();
      
      // Initialize providers
      final authProvider = context.read<AuthProvider>();
      final stationsProvider = context.read<StationsProvider>();
      final reservationsProvider = context.read<ReservationsProvider>();
      
      // Initialize all providers
      await Future.wait([
        authProvider.initialize(),
        stationsProvider.initialize(),
        reservationsProvider.initialize(),
      ]);
      
      // Wait minimum time for splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to appropriate screen
      if (mounted) {
        if (authProvider.isLoggedIn) {
          // Check if there's an active reservation
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.bike,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // App Name
                      Text(
                        AppConstants.appName,
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
                          'Sistema de reserva de plazas\ninteligentes para bicicletas',
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
                        'Inicializando...',
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
