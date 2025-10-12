import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/stations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/stat_card.dart';
import '../../services/navigation_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ReservationsProvider, StationsProvider>(
      builder: (context, authProvider, reservationsProvider, stationsProvider, child) {
        final user = authProvider.user;
        final stats = reservationsProvider.getStatistics();
        final favoriteStations = stationsProvider.favoriteStations;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.profileGradient,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Quick Stats
                _buildQuickStats(stats),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Detailed Statistics
                _buildDetailedStats(stats, favoriteStations.length),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Profile Actions
                _buildProfileActions(context, authProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.user,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // User Info
            Text(
              user?.email ?? 'Usuario',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              'Miembro desde ${AppHelpers.formatDate(DateTime.now().subtract(const Duration(days: 30)))}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Resumen de actividad',
                style: AppTextStyles.heading3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatItem(
                    'Reservas totales',
                    stats['totalReservations'].toString(),
                    LucideIcons.bike,
                    AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildQuickStatItem(
                    'Tiempo total',
                    AppHelpers.formatDuration(Duration(seconds: stats['totalUsageTime'])),
                    LucideIcons.clock,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> stats, int favoriteStationsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas detalladas',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.md),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          children: [
            _buildCustomStatCard(
              icon: Icons.check_circle,
              title: 'Completadas',
              value: stats['completedReservations'].toString(),
              subtitle: '${stats['completionRate']}% éxito',
              color: AppColors.success,
            ),
            StatCard(
              icon: Icons.cancel,
              title: 'Canceladas',
              value: stats['cancelledReservations'].toString(),
              subtitle: '${stats['cancellationRate']}% del total',
              color: AppColors.error,
            ),
            StatCard(
              icon: Icons.access_time,
              title: 'Expiradas',
              value: stats['expiredReservations'].toString(),
              subtitle: 'Por timeout',
              color: Colors.orange,
            ),
            StatCard(
              icon: Icons.star,
              title: 'Favoritos',
              value: favoriteStationsCount.toString(),
              subtitle: 'Estaciones marcadas',
              color: AppColors.favorite,
            ),
            StatCard(
              icon: LucideIcons.clock,
              title: 'Tiempo promedio',
              value: AppHelpers.formatDuration(Duration(seconds: stats['averageUsageTime'])),
              subtitle: 'Por reserva',
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildProfileActions(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración de cuenta',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.md),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.key),
                title: const Text('Cambiar contraseña'),
                subtitle: const Text('Actualiza tu contraseña de acceso'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => NavigationService.pushNamed(AppRoutes.changePassword),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.userMinus),
                title: const Text('Eliminar cuenta'),
                subtitle: const Text('Eliminar permanentemente tu cuenta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => NavigationService.pushNamed(AppRoutes.deleteUser),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.logOut),
                title: const Text('Cerrar sesión'),
                subtitle: const Text('Salir de tu cuenta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _handleLogout(context, authProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await AppHelpers.showConfirmationDialog(
      context,
      title: '¿Cerrar sesión?',
      content: '¿Estás seguro de que quieres cerrar tu sesión?',
      confirmText: 'Cerrar sesión',
      cancelText: 'Cancelar',
    );

    if (!confirmed) return;

    try {
      await authProvider.logout();
      if (context.mounted) {
        NavigationService.pushNamedAndClearStack(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        AppHelpers.showErrorSnackBar(context, 'Error al cerrar sesión');
      }
    }
  }

  Widget _buildCustomStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11, // Smaller font size
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Value
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Subtitle
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
