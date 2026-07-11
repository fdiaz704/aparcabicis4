import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
        AppHelpers.showErrorSnackBar(context, context.l10n.createUserError);
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
                        context.l10n.createUserTitle,
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
                              labelText: context.l10n.createUserEmailLabel,
                              prefixIcon: Icon(PlatformIcons.mail),
                              hintText: context.l10n.createUserEmailHint,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.l10n.createUserEmailRequired;
                              }
                              if (!AppHelpers.isValidEmail(value)) {
                                return context.l10n.createUserEmailInvalid;
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
                              labelText: context.l10n.createUserPasswordLabel,
                              prefixIcon: Icon(PlatformIcons.key),
                              hintText: context.l10n.createUserPasswordHint,
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
                                return context.l10n.createUserPasswordRequired;
                              }
                              if (value.length < AppConstants.minPasswordLength) {
                                return context.l10n.createUserPasswordTooShort(AppConstants.minPasswordLength);
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
                              labelText: context.l10n.createUserConfirmPasswordLabel,
                              prefixIcon: Icon(PlatformIcons.key),
                              hintText: context.l10n.createUserConfirmPasswordHint,
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
                                return context.l10n.createUserConfirmPasswordRequired;
                              }
                              if (value != _passwordController.text) {
                                return context.l10n.createUserPasswordMismatch;
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
                                  child: Text(context.l10n.createUserCancelButton),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleCreateUser,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(context.l10n.createUserSubmitButton),
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
