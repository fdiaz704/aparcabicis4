import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';

class SendPasswordScreen extends StatefulWidget {
  const SendPasswordScreen({super.key});

  @override
  State<SendPasswordScreen> createState() => _SendPasswordScreenState();
}

class _SendPasswordScreenState extends State<SendPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleSendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        if (result['success']) {
          setState(() => _emailSent = true);
          AppHelpers.showSuccessSnackBar(context, result['message']);
        } else {
          AppHelpers.showErrorSnackBar(context, result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.sendPasswordError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSendAgain() async {
    setState(() => _emailSent = false);
    await _handleSendEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                        context.l10n.sendPasswordTitle,
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
                  child: _emailSent ? _buildEmailSentView() : _buildEmailFormView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFormView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(PlatformIcons.info, color: Colors.blue),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.sendPasswordInstructions,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.l10n.sendPasswordEmailLabel,
                    prefixIcon: Icon(PlatformIcons.mail),
                    hintText: context.l10n.sendPasswordEmailHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.sendPasswordEmailRequired;
                    }
                    if (!AppHelpers.isValidEmail(value)) {
                      return context.l10n.sendPasswordEmailInvalid;
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
                        child: Text(context.l10n.sendPasswordCancelButton),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendEmail,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(context.l10n.sendPasswordSubmitButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Success Alert
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.sendPasswordSuccessAlert,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Confirmation Message
          Text(
            context.l10n.sendPasswordConfirmationMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            _emailController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Additional Instructions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.sendPasswordAdditionalTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(context.l10n.sendPasswordTip1),
                Text(context.l10n.sendPasswordTip2),
                Text(context.l10n.sendPasswordTip3),
                Text(context.l10n.sendPasswordTip4),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleSendAgain,
                  child: Text(context.l10n.sendPasswordSendAgainButton),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => NavigationService.pop(),
                  child: Text(context.l10n.sendPasswordBackToLoginButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
