import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parkings_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final authProvider = context.read<AuthProvider>();
      // "Recuérdame" only restores the email; the password is never stored.
      final savedEmail = await authProvider.getSavedEmail();

      if (savedEmail != null && savedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Load saved email error: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );

      if (!mounted) return;

      if (!success) {
        AppHelpers.showErrorSnackBar(context, context.l10n.loginInvalidCredentials);
        return;
      }

      // Tras el login, el bootstrap trae perfil, parámetros del sistema y la
      // reserva en curso en una sola llamada (RF-B.1).
      final sessionProvider = context.read<SessionProvider>();
      final reservationsProvider = context.read<ReservationsProvider>();
      context.read<ParkingsProvider>().resetFilters();

      await sessionProvider.load();
      await reservationsProvider.initialize();

      if (!mounted) return;

      AppHelpers.showSuccessSnackBar(context, context.l10n.loginSuccess);

      // Si hay uso en curso, se navega directamente a él (RF-B.3).
      if (reservationsProvider.hasActiveReservation) {
        NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
      } else {
        NavigationService.pushNamedAndClearStack(AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.loginError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.loginGradient,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top - 
                               MediaQuery.of(context).padding.bottom - 
                               (AppSpacing.lg * 2),
                  ),
                  child: Column(
                    children: [
                    // Header with menu button
                    Row(
                      children: [
                        IconButton(
                          onPressed: _toggleMenu,
                          icon: const Icon(LucideIcons.menu),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Logo and Title
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.bike,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      context.l10n.appName,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Login Form
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: context.l10n.loginEmailLabel,
                              labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: context.l10n.loginEmailHint,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(LucideIcons.mail, color: AppColors.primary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.loginEmailRequired;
                              }
                              if (!AppHelpers.isValidEmail(value)) {
                                return context.l10n.loginEmailInvalid;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: context.l10n.loginPasswordLabel,
                              labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: context.l10n.loginPasswordHint,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(LucideIcons.keyRound, color: AppColors.primary),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
                                icon: Icon(
                                  _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.loginPasswordRequired;
                              }
                              if (value.length < AppConstants.minPasswordLength) {
                                return context.l10n.loginPasswordTooShort(AppConstants.minPasswordLength);
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Remember Me Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                activeColor: AppColors.primary,
                              ),
                              Text(
                                context.l10n.loginRememberMe,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(context.l10n.loginSignInButton),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
          ),
          
          // Menu Overlay
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(LucideIcons.userPlus),
                            title: Text(context.l10n.loginMenuCreateUser),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.createUser);
                            },
                          ),
                          ListTile(
                            leading: const Icon(LucideIcons.userMinus),
                            title: Text(context.l10n.loginMenuDeleteUser),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.deleteUser);
                            },
                          ),
                          ListTile(
                            leading: const Icon(LucideIcons.key),
                            title: Text(context.l10n.loginMenuChangePassword),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.changePassword);
                            },
                          ),
                          ListTile(
                            leading: const Icon(LucideIcons.mail),
                            title: Text(context.l10n.loginMenuRecoverPassword),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.sendPassword);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
