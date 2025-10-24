import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _buildSectionHeader('Configuración de la aplicación'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Notificaciones',
              'Recibir notificaciones de reservas y recordatorios',
              PlatformIcons.notifications,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Modo oscuro',
              'Usar tema oscuro en la aplicación',
              PlatformIcons.darkMode,
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildInfoTile(
              'Idioma',
              'Español',
              PlatformIcons.language,
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Account Settings
          _buildSectionHeader('Cuenta'),
          _buildSettingsCard([
            _buildNavigationTile(
              'Cambiar contraseña',
              'Actualizar tu contraseña de acceso',
              PlatformIcons.key,
              () => NavigationService.pushNamed(AppRoutes.changePassword),
            ),
            _buildNavigationTile(
              'Eliminar cuenta',
              'Eliminar permanentemente tu cuenta',
              PlatformIcons.delete,
              () => NavigationService.pushNamed(AppRoutes.deleteUser),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Help & Support
          _buildSectionHeader('Ayuda y soporte'),
          _buildSettingsCard([
            _buildNavigationTile(
              'Tutorial',
              'Aprende a usar la aplicación',
              PlatformIcons.help,
              () => NavigationService.pushNamed(AppRoutes.help),
            ),
            _buildNavigationTile(
              'Preguntas frecuentes',
              'Encuentra respuestas a dudas comunes',
              PlatformIcons.help,
              () => _showFAQ(),
            ),
            _buildNavigationTile(
              'Llamar a soporte',
              'Contactar con nuestro equipo de soporte',
              PlatformIcons.phone,
              () => _contactSupport(),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // About
          _buildSectionHeader('Acerca de'),
          _buildSettingsCard([
            _buildInfoTile(
              'Versión',
              '1.0.0',
              PlatformIcons.info,
            ),
            _buildNavigationTile(
              'Términos de servicio',
              'Lee nuestros términos y condiciones',
              PlatformIcons.info,
              () => _showTerms(),
            ),
            _buildNavigationTile(
              'Política de privacidad',
              'Información sobre el manejo de tus datos',
              PlatformIcons.privacy,
              () => _showPrivacyPolicy(),
            ),
          ]),

        ],
      ),
    );
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
      activeColor: AppColors.primary,
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
      isScrollControlled: true,
      child: _buildFAQSheet(),
    );
  }

  Widget _buildFAQSheet() {
    final faqs = [
      {
        'question': '¿Cómo reservo una plaza?',
        'answer': 'Ve a la sección de Estaciones, selecciona una estación disponible y presiona "Reservar". Tendrás 30 minutos para llegar.',
      },
      {
        'question': '¿Puedo cancelar mi reserva?',
        'answer': 'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa antes de 30 minutos desde el momento en que se efectuó la reserva.',
      },
      {
        'question': '¿Cuánto tiempo puedo usar una plaza?',
        'answer': 'Puedes usar una plaza por un máximo de 14 horas. Después de este tiempo, la plaza se liberará automáticamente.',
      },
      {
        'question': '¿Qué pasa si no llego a tiempo?',
        'answer': 'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible.',
      },
      {
        'question': '¿Puedo tener múltiples reservas?',
        'answer': 'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.',
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
              const Expanded(
                child: Text(
                  'Preguntas frecuentes',
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
    if (!success && context.mounted) {
      AppHelpers.showErrorSnackBar(
        context,
        'No se puede abrir el marcador automáticamente.\nPor favor llama manualmente al $phoneNumber',
      );
    }
  }

  void _showTerms() {
    AppHelpers.showInfoSnackBar(
      context,
      'Términos de servicio - Funcionalidad en desarrollo',
    );
  }

  void _showPrivacyPolicy() {
    AppHelpers.showInfoSnackBar(
      context,
      'Política de privacidad - Funcionalidad en desarrollo',
    );
  }

}
