import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
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
      final credentials = await authProvider.getSavedCredentials();
      
      debugPrint('Loading saved credentials: $credentials');
      
      if (credentials['email'] != null && credentials['password'] != null) {
        debugPrint('Found saved credentials, filling fields');
        setState(() {
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
          _rememberMe = true;
        });
      } else {
        debugPrint('No saved credentials found');
      }
    } catch (e) {
      debugPrint('Load saved credentials error: $e');
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

      if (mounted) {
        if (success) {
          AppHelpers.showSuccessSnackBar(context, 'Inicio de sesión exitoso');
          NavigationService.pushNamedAndClearStack(AppRoutes.main);
        } else {
          AppHelpers.showErrorSnackBar(context, 'Email o contraseña incorrectos');
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, 'Error al iniciar sesión');
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
                          icon: Icon(PlatformIcons.menu),
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
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        PlatformIcons.bike,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      AppConstants.appName,
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
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(PlatformIcons.mail),
                              hintText: 'ejemplo@correo.com',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              }
                              if (!AppHelpers.isValidEmail(value)) {
                                return 'Por favor ingresa un email válido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(PlatformIcons.key),
                              hintText: 'Mínimo 8 caracteres',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showPassword = !_showPassword);
                                },
                                icon: Icon(
                                  _showPassword ? PlatformIcons.visibilityOff : PlatformIcons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < AppConstants.minPasswordLength) {
                                return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
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
                              const Text('Recuérdame'),
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
                                  : const Text('Iniciar sesión'),
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
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(PlatformIcons.add),
                            title: const Text('Crear usuario'),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.createUser);
                            },
                          ),
                          ListTile(
                            leading: Icon(PlatformIcons.delete),
                            title: const Text('Eliminar usuario'),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.deleteUser);
                            },
                          ),
                          ListTile(
                            leading: Icon(PlatformIcons.key),
                            title: const Text('Cambiar contraseña'),
                            onTap: () {
                              _toggleMenu();
                              NavigationService.pushNamed(AppRoutes.changePassword);
                            },
                          ),
                          ListTile(
                            leading: Icon(PlatformIcons.mail),
                            title: const Text('Recuperar contraseña'),
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
