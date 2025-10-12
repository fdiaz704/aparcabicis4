import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/bike_station.dart';
import '../providers/stations_provider.dart';
import '../providers/reservations_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/navigation_service.dart';

class BikeStationCard extends StatelessWidget {
  final BikeStation station;
  final VoidCallback? onReserve;

  const BikeStationCard({
    super.key,
    required this.station,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationsProvider, ReservationsProvider>(
      builder: (context, stationsProvider, reservationsProvider, child) {
        final isFavorite = stationsProvider.isFavorite(station.id);
        final hasAvailableSpots = station.availableSpots > 0;
        final canReserve = hasAvailableSpots && !reservationsProvider.hasActiveReservation;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Station Name
                    Expanded(
                      child: Text(
                        station.name,
                        style: AppTextStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Favorite Button
                    IconButton(
                      onPressed: () => _toggleFavorite(context, stationsProvider),
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? AppColors.favorite : Colors.grey,
                      ),
                      tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                    ),
                    
                    // Availability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      child: Text(
                        AppHelpers.getAvailabilityBadge(station.availableSpots, station.totalSpots),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Address Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        station.address,
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Bottom Row
                Row(
                  children: [
                    // Availability Text
                    Row(
                      children: [
                        Icon(
                          LucideIcons.bike,
                          size: 16,
                          color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AppHelpers.getAvailabilityText(station.availableSpots, station.totalSpots),
                          style: TextStyle(
                            color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Reserve Button
                    ElevatedButton(
                      onPressed: canReserve ? () => _handleReserve(context, reservationsProvider) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canReserve ? AppColors.primary : Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      ),
                      child: Text(
                        _getButtonText(canReserve, reservationsProvider.hasActiveReservation),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, StationsProvider stationsProvider) {
    stationsProvider.toggleFavorite(station.id);
    
    final isFavorite = stationsProvider.isFavorite(station.id);
    final message = isFavorite 
        ? '${station.name} añadido a favoritos'
        : '${station.name} eliminado de favoritos';
    
    AppHelpers.showInfoSnackBar(context, message);
  }

  Future<void> _handleReserve(BuildContext context, ReservationsProvider reservationsProvider) async {
    if (station.availableSpots <= 0) {
      AppHelpers.showErrorSnackBar(context, 'No hay plazas disponibles en esta estación');
      return;
    }

    if (reservationsProvider.hasActiveReservation) {
      AppHelpers.showErrorSnackBar(context, 'Ya tienes una reserva activa');
      return;
    }

    // Reservar directamente sin modal de confirmación

    try {
      // Update station availability
      final stationsProvider = context.read<StationsProvider>();
      stationsProvider.updateStationAvailability(station.id, station.availableSpots - 1);

      // Create reservation
      final success = await reservationsProvider.createReservation(station);

      if (success) {
        AppHelpers.showSuccessSnackBar(
          context, 
          'Reserva creada exitosamente en ${station.name}',
        );
        
        // Navigate to active reservation screen
        NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
      } else {
        // Restore station availability if reservation failed
        stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);
        AppHelpers.showErrorSnackBar(context, 'Error al crear la reserva');
      }
    } catch (e) {
      // Restore station availability on error
      final stationsProvider = context.read<StationsProvider>();
      stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);
      AppHelpers.showErrorSnackBar(context, 'Error al crear la reserva');
    }

    // Call optional callback
    onReserve?.call();
  }

  String _getButtonText(bool canReserve, bool hasActiveReservation) {
    if (hasActiveReservation) {
      return 'Reserva activa';
    } else if (!canReserve) {
      return 'Sin plazas';
    } else {
      return 'Reservar';
    }
  }
}
