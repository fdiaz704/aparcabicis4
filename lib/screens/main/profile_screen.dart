import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/parkings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
import '../../widgets/stat_card.dart';
import '../../services/navigation_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ReservationsProvider, ParkingsProvider>(
      builder: (context, authProvider, reservationsProvider, parkingsProvider, child) {
        final user = authProvider.user;
        final stats = reservationsProvider.getStatistics();
        final favoriteParkings = parkingsProvider.favoriteParkings;

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
                _buildProfileHeader(context, user),

                const SizedBox(height: AppSpacing.xl),

                // Quick Stats
                _buildQuickStats(context, stats),

                const SizedBox(height: AppSpacing.xl),

                // Detailed Statistics
                _buildDetailedStats(context, stats, favoriteParkings.length),
                
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

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
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
              child: Icon(
                PlatformIcons.user,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // User Info
            Text(
              user?.email ?? context.l10n.profileDefaultUser,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              context.l10n.profileMemberSince(AppHelpers.formatDate(DateTime.now().subtract(const Duration(days: 30)))),
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.l10n.profileActivitySummary,
                style: AppTextStyles.heading3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildQuickStatItem(
                    context.l10n.profileTotalReservations,
                    stats['totalReservations'].toString(),
                    PlatformIcons.bike,
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
                    context.l10n.profileTotalTime,
                    AppHelpers.formatDuration(Duration(seconds: stats['totalUsageTime'])),
                    PlatformIcons.clock,
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

  Widget _buildDetailedStats(BuildContext context, Map<String, dynamic> stats, int favoriteParkingsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.profileDetailedStats,
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
              icon: PlatformIcons.checkmarkCircle,
              title: context.l10n.profileCompleted,
              value: stats['completedReservations'].toString(),
              subtitle: context.l10n.profileSuccessRate(stats['completionRate'].toString()),
              color: AppColors.success,
            ),
            StatCard(
              icon: PlatformIcons.close,
              title: context.l10n.profileCancelled,
              value: stats['cancelledReservations'].toString(),
              subtitle: context.l10n.profileCancellationRate(stats['cancellationRate'].toString()),
              color: AppColors.error,
            ),
            StatCard(
              icon: Icons.access_time,
              title: context.l10n.profileExpired,
              value: stats['expiredReservations'].toString(),
              subtitle: context.l10n.profileByTimeout,
              color: Colors.orange,
            ),
            StatCard(
              icon: PlatformIcons.star,
              title: context.l10n.profileFavorites,
              value: favoriteParkingsCount.toString(),
              subtitle: context.l10n.profileMarkedParkings,
              color: AppColors.favorite,
            ),
            StatCard(
              icon: PlatformIcons.clock,
              title: context.l10n.profileAverageTime,
              value: AppHelpers.formatDuration(Duration(seconds: stats['averageUsageTime'])),
              subtitle: context.l10n.profilePerReservation,
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
          context.l10n.profileAccountSettings,
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.md),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(PlatformIcons.key),
                title: Text(context.l10n.profileChangePassword),
                subtitle: Text(context.l10n.profileChangePasswordSubtitle),
                trailing: Icon(PlatformIcons.chevronRight),
                onTap: () => NavigationService.pushNamed(AppRoutes.changePassword),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(PlatformIcons.delete),
                title: Text(context.l10n.profileDeleteAccount),
                subtitle: Text(context.l10n.profileDeleteAccountSubtitle),
                trailing: Icon(PlatformIcons.chevronRight),
                onTap: () => NavigationService.pushNamed(AppRoutes.deleteUser),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(PlatformIcons.close),
                title: Text(context.l10n.profileLogout),
                subtitle: Text(context.l10n.profileLogoutSubtitle),
                trailing: Icon(PlatformIcons.chevronRight),
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
      title: context.l10n.profileLogoutConfirmTitle,
      content: context.l10n.profileLogoutConfirmContent,
      confirmText: context.l10n.profileLogout,
      cancelText: context.l10n.profileCancel,
    );

    if (!confirmed) return;

    try {
      await authProvider.logout();
      if (context.mounted) {
        NavigationService.pushNamedAndClearStack(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.profileLogoutError);
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
