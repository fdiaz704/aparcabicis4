import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../utils/constants.dart';
import '../../services/navigation_service.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Tutorial'),
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tutorial', icon: Icon(Icons.play_circle_outline)),
            Tab(text: 'FAQ', icon: Icon(Icons.help_outline)),
            Tab(text: 'Contacto', icon: Icon(Icons.support_agent)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTutorialTab(),
          _buildFAQTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildTutorialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildTutorialSection(
            'Bienvenido a Aparcabicis',
            'Tu aplicación para reservar plazas de aparcamiento para bicicletas de forma inteligente.',
            LucideIcons.bike,
            AppColors.primary,
          ),

          // How to Reserve
          _buildTutorialSection(
            'Cómo hacer una reserva',
            '1. Ve a la sección "Estaciones"\n'
            '2. Selecciona una estación disponible\n'
            '3. Presiona "Reservar"\n'
            '4. Tienes 30 minutos para llegar\n'
            '5. Abre la puerta para comenzar a usar la plaza',
            Icons.list_alt,
            AppColors.info,
          ),

          // Using the App
          _buildTutorialSection(
            'Usando la aplicación',
            '• Lista: Ve todas las estaciones en formato lista\n'
            '• Mapa: Visualiza las estaciones en un mapa interactivo\n'
            '• Favoritos: Marca tus estaciones preferidas\n'
            '• Filtros: Busca por disponibilidad o favoritos\n'
            '• Historial: Revisa tus reservas anteriores',
            Icons.apps,
            Colors.purple,
          ),

          // Active Reservation
          _buildTutorialSection(
            'Reserva activa',
            'Cuando tengas una reserva activa:\n\n'
            '• Estado "Reservada": Tienes 30 minutos para llegar\n'
            '• Estado "En uso": Puedes usar la plaza hasta 2 horas\n'
            '• Puedes abrir la puerta tantas veces como necesites\n'
            '• Finaliza tu uso cuando termines',
            Icons.access_time,
            Colors.orange,
          ),

          // Tips
          _buildTutorialSection(
            'Consejos útiles',
            '• Marca como favoritas las estaciones que uses frecuentemente\n'
            '• Revisa tu historial para ver estadísticas de uso\n'
            '• Activa las notificaciones para recordatorios\n'
            '• Usa los filtros para encontrar estaciones más rápido\n'
            '• Cancela tu reserva si no vas a usarla',
            Icons.lightbulb,
            Colors.amber,
          ),

          // Interactive Demo Button
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startInteractiveDemo,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar demo interactivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    final faqs = [
      {
        'question': '¿Cómo reservo una plaza?',
        'answer': 'Ve a la sección de Estaciones, selecciona una estación disponible y presiona "Reservar". Tendrás 30 minutos para llegar y abrir la puerta.',
      },
      {
        'question': '¿Puedo cancelar mi reserva?',
        'answer': 'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa presionando "Cancelar reserva". Esto liberará la plaza para otros usuarios.',
      },
      {
        'question': '¿Cuánto tiempo puedo usar una plaza?',
        'answer': 'Puedes usar una plaza por un máximo de 2 horas. El timer comenzará cuando abras la puerta por primera vez.',
      },
      {
        'question': '¿Qué pasa si no llego a tiempo?',
        'answer': 'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible para otros usuarios.',
      },
      {
        'question': '¿Puedo tener múltiples reservas?',
        'answer': 'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.',
      },
      {
        'question': '¿Cómo marco una estación como favorita?',
        'answer': 'Presiona el icono de estrella en cualquier estación para marcarla como favorita. Luego puedes filtrar para ver solo tus favoritas.',
      },
      {
        'question': '¿Puedo ver mi historial de reservas?',
        'answer': 'Sí, ve a la pestaña "Historial" para ver todas tus reservas anteriores, estadísticas de uso y filtrar por estado.',
      },
      {
        'question': '¿La aplicación funciona sin internet?',
        'answer': 'Necesitas conexión a internet para hacer reservas y abrir puertas. Sin embargo, puedes ver tu historial y configuración sin conexión.',
      },
      {
        'question': '¿Cómo cambio mi contraseña?',
        'answer': 'Ve a Perfil > Configuración de cuenta > Cambiar contraseña, o desde Ajustes > Cuenta > Cambiar contraseña.',
      },
      {
        'question': '¿Hay algún coste por usar el servicio?',
        'answer': 'El servicio básico es gratuito. Solo pagas si excedes el tiempo máximo de uso o por servicios premium adicionales.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ExpansionTile(
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
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacta con nosotros',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Contact Methods
          _buildContactMethod(
            'Email de soporte',
            'soporte@aparcabicis.com',
            'Para problemas técnicos y consultas generales',
            Icons.email,
            AppColors.primary,
          ),

          _buildContactMethod(
            'Teléfono de emergencia',
            '+34 900 123 456',
            'Disponible 24/7 para emergencias',
            Icons.phone,
            Colors.red,
          ),

          _buildContactMethod(
            'Chat en vivo',
            'Disponible de 9:00 a 18:00',
            'Respuesta inmediata durante horario laboral',
            Icons.chat,
            Colors.green,
          ),

          _buildContactMethod(
            'Redes sociales',
            '@AparcabicisApp',
            'Síguenos para novedades y actualizaciones',
            Icons.share,
            Colors.blue,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Actions
          Text(
            'Acciones rápidas',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.md),

          _buildQuickAction(
            'Reportar un problema',
            'Informa sobre estaciones dañadas o problemas técnicos',
            Icons.report_problem,
            Colors.orange,
            _reportProblem,
          ),

          _buildQuickAction(
            'Sugerir mejora',
            'Comparte tus ideas para mejorar la aplicación',
            Icons.lightbulb_outline,
            Colors.amber,
            _suggestImprovement,
          ),

          _buildQuickAction(
            'Valorar la app',
            'Ayúdanos dejando una reseña en la tienda',
            Icons.star_rate,
            AppColors.favorite,
            _rateApp,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Office Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oficinas centrales',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Aparcabicis S.L.'),
                  const Text('Calle Mayor, 123'),
                  const Text('28001 Madrid, España'),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Horario de atención:'),
                  const Text('Lunes a Viernes: 9:00 - 18:00'),
                  const Text('Sábados: 10:00 - 14:00'),
                  const Text('Domingos: Cerrado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection(String title, String content, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(String title, String value, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildQuickAction(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _startInteractiveDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo interactivo'),
        content: const Text('El demo interactivo te guiará paso a paso por todas las funciones de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would start the interactive demo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo interactivo - Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _reportProblem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reportar problema - Funcionalidad en desarrollo')),
    );
  }

  void _suggestImprovement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sugerir mejora - Funcionalidad en desarrollo')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Valorar app - Funcionalidad en desarrollo')),
    );
  }
}
