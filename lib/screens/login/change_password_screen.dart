import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/navigation_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;
  bool _isLoading = false;

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.changePassword(
        email: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmNewPasswordController.text,
      );

      if (mounted) {
        if (result['success']) {
          AppHelpers.showSuccessSnackBar(context, result['message']);
          await Future.delayed(const Duration(milliseconds: 1500));
          NavigationService.pop();
        } else {
          AppHelpers.showErrorSnackBar(context, result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, 'Error al cambiar la contraseña');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => NavigationService.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text(
                        'Cambiar Contraseña',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail),
                              hintText: 'Tu email actual',
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
                          
                          // Current Password Field
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: !_showCurrentPassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña actual',
                              prefixIcon: const Icon(Icons.vpn_key),
                              hintText: 'Tu contraseña actual',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showCurrentPassword = !_showCurrentPassword);
                                },
                                icon: Icon(
                                  _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña actual';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // New Password Field
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
                              prefixIcon: const Icon(Icons.vpn_key),
                              hintText: 'Mínimo 8 caracteres',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showNewPassword = !_showNewPassword);
                                },
                                icon: Icon(
                                  _showNewPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa una nueva contraseña';
                              }
                              if (value.length < AppConstants.minPasswordLength) {
                                return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
                              }
                              if (value == _currentPasswordController.text) {
                                return 'La nueva contraseña debe ser diferente a la actual';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Confirm New Password Field
                          TextFormField(
                            controller: _confirmNewPasswordController,
                            obscureText: !_showConfirmNewPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar nueva contraseña',
                              prefixIcon: const Icon(Icons.vpn_key),
                              hintText: 'Repite la nueva contraseña',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showConfirmNewPassword = !_showConfirmNewPassword);
                                },
                                icon: Icon(
                                  _showConfirmNewPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu nueva contraseña';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Las contraseñas nuevas no coinciden';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : () => NavigationService.pop(),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleChangePassword,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Cambiar contraseña',
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
