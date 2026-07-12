import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_widgets.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Settings
          _buildSectionHeader(context.l10n.settingsAppSection),
          _buildSettingsCard([
            _buildSwitchTile(
              context.l10n.settingsNotifications,
              context.l10n.settingsNotificationsSubtitle,
              PlatformIcons.notifications,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              context.l10n.settingsDarkMode,
              context.l10n.settingsDarkModeSubtitle,
              PlatformIcons.darkMode,
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            // Acceso biométrico (RF-1.6): gobierna si la app se desbloquea con
            // huella/Face ID. Desactivarlo NO cierra la sesión.
            _buildSwitchTile(
              context.l10n.settingsBiometric,
              context.l10n.settingsBiometricSubtitle,
              Icons.fingerprint,
              context.watch<AuthProvider>().isBiometricEnabled,
              _handleBiometricToggle,
            ),
            _buildInfoTile(
              context.l10n.settingsLanguage,
              context.l10n.settingsLanguageValue,
              PlatformIcons.language,
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Account Settings
          _buildSectionHeader(context.l10n.settingsAccountSection),
          _buildSettingsCard([
            _buildNavigationTile(
              context.l10n.settingsChangePassword,
              context.l10n.settingsChangePasswordSubtitle,
              PlatformIcons.key,
              () => NavigationService.pushNamed(AppRoutes.changePassword),
            ),
            _buildNavigationTile(
              context.l10n.settingsDeleteAccount,
              context.l10n.settingsDeleteAccountSubtitle,
              PlatformIcons.delete,
              () => NavigationService.pushNamed(AppRoutes.deleteUser),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Help & Support
          _buildSectionHeader(context.l10n.settingsHelpSection),
          _buildSettingsCard([
            _buildNavigationTile(
              context.l10n.settingsTutorial,
              context.l10n.settingsTutorialSubtitle,
              PlatformIcons.help,
              () => NavigationService.pushNamed(AppRoutes.help),
            ),
            _buildNavigationTile(
              context.l10n.settingsFaq,
              context.l10n.settingsFaqSubtitle,
              PlatformIcons.help,
              () => _showFAQ(),
            ),
            _buildNavigationTile(
              context.l10n.settingsCallSupport,
              context.l10n.settingsCallSupportSubtitle,
              PlatformIcons.phone,
              () => _contactSupport(),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // About
          _buildSectionHeader(context.l10n.settingsAboutSection),
          _buildSettingsCard([
            _buildInfoTile(
              context.l10n.settingsVersion,
              '1.0.0',
              PlatformIcons.info,
            ),
            _buildNavigationTile(
              context.l10n.settingsTerms,
              context.l10n.settingsTermsSubtitle,
              PlatformIcons.info,
              () => _showTerms(),
            ),
            _buildNavigationTile(
              context.l10n.settingsPrivacy,
              context.l10n.settingsPrivacySubtitle,
              PlatformIcons.privacy,
              () => _showPrivacyPolicy(),
            ),
          ]),

        ],
      ),
    );
  }

  /// Activa/desactiva el acceso biométrico (RF-1.6).
  ///
  /// Al activarlo se pide una verificación de prueba: si no se supera, no se
  /// activa. Al desactivarlo, la sesión se mantiene y deja de pedirse la huella.
  Future<void> _handleBiometricToggle(bool enable) async {
    final authProvider = context.read<AuthProvider>();

    if (!enable) {
      await authProvider.disableBiometrics();
      if (!mounted) return;
      AppHelpers.showInfoSnackBar(context, context.l10n.settingsBiometricDisabled);
      return;
    }

    final reason = context.l10n.biometricPromptReason;
    final enabled = await authProvider.enableBiometrics(reason);
    if (!mounted) return;

    if (enabled) {
      AppHelpers.showSuccessSnackBar(context, context.l10n.biometricEnabledSuccess);
    } else {
      AppHelpers.showInfoSnackBar(context, context.l10n.biometricUnavailable);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.heading3,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: AppColors.primary),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(PlatformIcons.chevronRight),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
      ),
    );
  }




  void _showFAQ() {
    PlatformWidgets.showAdaptiveModalBottomSheet(
      context: context,
      child: _buildFAQSheet(),
    );
  }

  Widget _buildFAQSheet() {
    final faqs = [
      {
        'question': context.l10n.settingsFaqQuestion1,
        'answer': context.l10n.settingsFaqAnswer1,
      },
      {
        'question': context.l10n.settingsFaqQuestion2,
        'answer': context.l10n.settingsFaqAnswer2,
      },
      {
        'question': context.l10n.settingsFaqQuestion3,
        'answer': context.l10n.settingsFaqAnswer3,
      },
      {
        'question': context.l10n.settingsFaqQuestion4,
        'answer': context.l10n.settingsFaqAnswer4,
      },
      {
        'question': context.l10n.settingsFaqQuestion5,
        'answer': context.l10n.settingsFaqAnswer5,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.settingsFaq,
                  style: AppTextStyles.heading2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PlatformWidgets.buildAdaptiveCloseButton(context),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        faq['answer']!,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport() async {
    const phoneNumber = '962910853';
    
    // Try multiple approaches to open phone dialer
    final List<Uri> phoneUris = [
      Uri.parse('tel:$phoneNumber'),
      Uri(scheme: 'tel', path: phoneNumber),
      Uri.parse('tel://$phoneNumber'),
    ];
    
    bool success = false;
    
    for (Uri phoneUri in phoneUris) {
      try {
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        success = true;
        break;
      } catch (e) {
        // Continue to next URI format
        continue;
      }
    }
    
    // If all methods failed, show error message
    if (!success && mounted) {
      AppHelpers.showErrorSnackBar(
        context,
        context.l10n.settingsCallSupportError(phoneNumber),
      );
    }
  }

  void _showTerms() {
    AppHelpers.showInfoSnackBar(
      context,
      context.l10n.settingsTermsInDevelopment,
    );
  }

  void _showPrivacyPolicy() {
    AppHelpers.showInfoSnackBar(
      context,
      context.l10n.settingsPrivacyInDevelopment,
    );
  }

}
