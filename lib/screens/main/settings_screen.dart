import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../config/city_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/preferences_provider.dart';
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
  /// Versión instalada para la tarjeta "Acerca de". Se lee una sola vez: es un
  /// canal de plataforma y no cambia mientras la app vive.
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferences = context.watch<PreferencesProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.settingsAppSection),
          _buildSettingsCard([
            // Solo persiste la preferencia: los avisos de reserva y uso son
            // locales y no la consultan. El push llega con el backend.
            _buildSwitchTile(
              l10n.settingsNotifications,
              l10n.settingsNotificationsSubtitle,
              PlatformIcons.notifications,
              preferences.notificationsEnabled,
              preferences.setNotificationsEnabled,
            ),
            // Acceso biométrico (RF-1.6): gobierna si la app se desbloquea con
            // huella/Face ID. Desactivarlo NO cierra la sesión.
            _buildSwitchTile(
              l10n.settingsBiometric,
              l10n.settingsBiometricSubtitle,
              Icons.fingerprint,
              context.watch<AuthProvider>().isBiometricEnabled,
              _handleBiometricToggle,
            ),
            _buildNavigationTile(
              l10n.settingsTheme,
              l10n.settingsThemeSubtitle,
              PlatformIcons.darkMode,
              _showThemePicker,
              trailing: _themeLabel(preferences.themeMode),
            ),
            _buildNavigationTile(
              l10n.settingsLanguage,
              _localeLabel(preferences.locale),
              PlatformIcons.language,
              _showLanguagePicker,
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          _buildSectionHeader(l10n.settingsHelpSection),
          _buildSettingsCard([
            _buildNavigationTile(
              l10n.settingsTutorial,
              l10n.settingsTutorialSubtitle,
              PlatformIcons.help,
              () => NavigationService.pushNamed(AppRoutes.help),
            ),
            _buildNavigationTile(
              l10n.settingsFaq,
              l10n.settingsFaqSubtitle,
              PlatformIcons.help,
              _showFAQ,
            ),
            _buildNavigationTile(
              l10n.settingsCallSupport,
              l10n.settingsCallSupportSubtitle,
              PlatformIcons.phone,
              _contactSupport,
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          _buildSectionHeader(l10n.settingsAboutSection),
          _buildAboutCard(),
        ],
      ),
    );
  }

  /// Tarjeta "Acerca de": todo lo dependiente de ciudad sale de [CityConfig],
  /// nunca de literales (RF-0).
  Widget _buildAboutCard() {
    final l10n = context.l10n;
    final city = context.read<CityConfig>();

    return _buildSettingsCard([
      FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          final info = snapshot.data;
          final version =
              info == null ? '—' : '${info.version} (${info.buildNumber})';
          return _buildInfoTile(
            l10n.settingsVersion,
            version,
            PlatformIcons.info,
          );
        },
      ),
      _buildInfoTile(l10n.settingsCity, city.name, PlatformIcons.location),
      _buildInfoTile(
        l10n.settingsPlatform,
        Platform.isIOS ? 'iOS' : 'Android',
        PlatformIcons.settings,
      ),
      _buildNavigationTile(
        l10n.settingsTerms,
        l10n.settingsTermsSubtitle,
        PlatformIcons.info,
        () => _openLink(city.termsUrl),
      ),
      _buildNavigationTile(
        l10n.settingsPrivacy,
        l10n.settingsPrivacySubtitle,
        PlatformIcons.privacy,
        () => _openLink(city.privacyUrl),
      ),
    ]);
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => context.l10n.settingsThemeSystem,
        ThemeMode.light => context.l10n.settingsThemeLight,
        ThemeMode.dark => context.l10n.settingsThemeDark,
      };

  String _localeLabel(Locale? locale) => switch (locale?.languageCode) {
        'es' => context.l10n.settingsLanguageSpanish,
        'ca' => context.l10n.settingsLanguageValencian,
        _ => context.l10n.settingsLanguageSystem,
      };

  Future<void> _showThemePicker() async {
    final preferences = context.read<PreferencesProvider>();
    await _showOptionsSheet<ThemeMode>(
      title: context.l10n.settingsTheme,
      selected: preferences.themeMode,
      options: {
        for (final mode in ThemeMode.values) mode: _themeLabel(mode),
      },
      onSelected: preferences.setThemeMode,
    );
  }

  /// Idiomas ofrecidos: los que declara la ciudad (RF-0.2), más "el del
  /// sistema". Nada de listas fijas aquí.
  Future<void> _showLanguagePicker() async {
    final preferences = context.read<PreferencesProvider>();
    final city = context.read<CityConfig>();
    await _showOptionsSheet<String>(
      title: context.l10n.settingsLanguage,
      selected: preferences.locale?.languageCode ?? '',
      options: {
        '': context.l10n.settingsLanguageSystem,
        for (final locale in city.supportedLocales)
          locale.languageCode: _localeLabel(locale),
      },
      onSelected: (code) =>
          preferences.setLocale(code.isEmpty ? null : Locale(code)),
    );
  }

  Future<void> _showOptionsSheet<T>({
    required String title,
    required T selected,
    required Map<T, String> options,
    required ValueChanged<T> onSelected,
  }) async {
    await PlatformWidgets.showAdaptiveModalBottomSheet<void>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.heading2)),
                PlatformWidgets.buildAdaptiveCloseButton(context),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final entry in options.entries)
              PlatformWidgets.buildAdaptiveRadioListTile<T>(
                title: entry.value,
                value: entry.key,
                groupValue: selected,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
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
    VoidCallback onTap, {
    String? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          Icon(PlatformIcons.chevronRight),
        ],
      ),
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

  /// Abre términos o privacidad en el navegador. Las URLs vienen de la ciudad.
  Future<void> _openLink(String url) async {
    var opened = false;
    final uri = Uri.tryParse(url);
    if (uri != null && url.isNotEmpty) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        opened = false;
      }
    }

    if (!opened && mounted) {
      AppHelpers.showErrorSnackBar(context, context.l10n.settingsLinkError);
    }
  }
}
