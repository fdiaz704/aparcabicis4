import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({super.key});

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _confirmationController = TextEditingController();
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  Future<void> _handleDeleteUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirmed = await AppHelpers.showConfirmationDialog(
      context,
      title: context.l10n.deleteUserConfirmTitle,
      content: context.l10n.deleteUserConfirmContent,
      confirmText: context.l10n.deleteUserConfirmButton,
      cancelText: context.l10n.deleteUserCancelButton,
      isDestructive: true,
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.deleteUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        confirmationText: _confirmationController.text,
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
        AppHelpers.showErrorSnackBar(context, context.l10n.deleteUserError);
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _confirmationController.dispose();
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
                      icon: Icon(PlatformIcons.chevronLeft),
                      color: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        context.l10n.deleteUserTitle,
                        style: const TextStyle(
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
                
                // Warning
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          context.l10n.deleteUserWarning,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            decoration: InputDecoration(
                              labelText: context.l10n.deleteUserEmailLabel,
                              prefixIcon: Icon(PlatformIcons.mail),
                              hintText: context.l10n.deleteUserEmailHint,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.deleteUserEmailRequired;
                              }
                              if (!AppHelpers.isValidEmail(value)) {
                                return context.l10n.deleteUserEmailInvalid;
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
                              labelText: context.l10n.deleteUserPasswordLabel,
                              prefixIcon: Icon(PlatformIcons.key),
                              hintText: context.l10n.deleteUserPasswordHint,
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
                                return context.l10n.deleteUserPasswordRequired;
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: context.l10n.deleteUserConfirmPasswordLabel,
                              prefixIcon: Icon(PlatformIcons.key),
                              hintText: context.l10n.deleteUserConfirmPasswordHint,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                                },
                                icon: Icon(
                                  _showConfirmPassword ? PlatformIcons.visibilityOff : PlatformIcons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.deleteUserConfirmPasswordRequired;
                              }
                              if (value != _passwordController.text) {
                                return context.l10n.deleteUserPasswordMismatch;
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Confirmation Text Field
                          TextFormField(
                            controller: _confirmationController,
                            decoration: InputDecoration(
                              labelText: context.l10n.deleteUserConfirmationLabel,
                              prefixIcon: const Icon(Icons.edit),
                              hintText: 'ELIMINAR',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.deleteUserConfirmationRequired;
                              }
                              if (!AppHelpers.isValidDeletionConfirmation(value)) {
                                return context.l10n.deleteUserConfirmationInvalid;
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
                                  child: Text(context.l10n.deleteUserCancelButton),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleDeleteUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(context.l10n.deleteUserSubmitButton),
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
